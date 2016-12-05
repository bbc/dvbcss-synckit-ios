//
//  UDPEndpoint.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 23/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "UDPEndpoint.h"
#if ! defined(UDPCOMMS_IPV4_ONLY)
#define UDPCOMMS_IPV4_ONLY 1
#endif
#import <SimpleLogger/SimpleLogger.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <fcntl.h>
#import <unistd.h>

NSString *const UdpSocketThreadName = @"SyncKitUDPSocketThread";

static NSThread *listenerThread;

@interface UDPEndpoint()

// redeclare as readwrite for private use

@property (nonatomic, copy,   readwrite) NSString *             hostName;
@property (nonatomic, copy,   readwrite) NSData *               hostAddress;
@property (nonatomic, assign, readwrite) NSUInteger             port;
@property (nonatomic, assign)             size_t                bufferSize;

// forward declarations

- (void)stopHostResolution;
- (void)stopWithError:(NSError *)error;
- (void)stopWithStreamError:(CFStreamError)streamError;
- (void)listenerThread;


@end


// send and receive buffers
uint8_t *recv_buf;
uint8_t *send_buf;

@implementation UDPEndpoint
{
    CFHostRef               _cfHost;
    //    CFSocketRef             _cfSocket;
    int                     sockfd;
    fd_set                  read_fd_set;
    BOOL                    continue_loop;
    
}

@synthesize delegate    = _delegate;
@synthesize hostName    = _hostName;
@synthesize hostAddress = _hostAddress;
@synthesize port        = _port;


- (id)initWithBufferSize:(size_t) size
{
    self = [super init];
    if (self != nil) {
        
        self.bufferSize = size;
        recv_buf = (uint8_t *) malloc(size);
        send_buf = (uint8_t *) malloc(size);
        
    }
    return self;
}

- (void)dealloc
{
    close(sockfd);
    
    _cfHost = nil;
    
    
    [self stop];
}

- (BOOL)isServer
{
    return self.hostName == nil;
}




- (uint8_t *) getSendBuffer
{
    return (uint8_t*) send_buf;
}

- (uint8_t *) getReceiveBuffer
{
    return (uint8_t*) recv_buf;
}

- (void)sendData:(NSData *)data toAddress:(NSData *)addr
// Called by both -sendData: and the server echoing code to send data
// via the socket.  addr is nil in the client case, whereupon the
// data is automatically sent to the hostAddress by virtue of the fact
// that the socket is connected to that address.
{
    int                     err;
    int                     sock;
    ssize_t                 bytesWritten;
    const struct sockaddr * addrPtr;
    socklen_t               addrLen;
    
    assert(data != nil);
    assert( (addr != nil) == self.isServer );
    assert( (addr == nil) || ([addr length] <= sizeof(struct sockaddr_storage)) );
    
    sock = self->sockfd;
    assert(sock >= 0);
    
    if (addr == nil) {
        addr = self.hostAddress;
        assert(addr != nil);
        addrPtr = NULL;
        addrLen = 0;
    } else {
        addrPtr = [addr bytes];
        addrLen = (socklen_t) [addr length];
    }
    
    bytesWritten = sendto(sock, [data bytes], [data length], 0, addrPtr, addrLen);
    
    if (bytesWritten < 0) {
        err = errno;
    } else  if (bytesWritten == 0) {
        err = EPIPE;
    } else {
        // We ignore any short writes, which shouldn't happen for UDP anyway.
        assert( (NSUInteger) bytesWritten == [data length] );
        err = 0;
    }
    
    if (err == 0) {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didSendData:toAddress:)] ) {
            [self.delegate didSendData:data toAddress:addr];
        }
    } else {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didFailToSendData:toAddress:error:)] ) {
            [self.delegate didFailToSendData:data toAddress:addr error:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
        }
    }
}


- (BOOL) checkForIncomingPackets:(uint32_t) timeout_us
{
    int result = 0;
    struct timeval timeout;
    
    timeout.tv_sec = timeout_us / 1000000;
    timeout.tv_usec =  timeout_us % 1000000;
    
    FD_ZERO (&read_fd_set);
    FD_SET (self->sockfd, &read_fd_set);
    
    result = select (FD_SETSIZE, &read_fd_set, NULL, NULL, &timeout);
    
    if (result > 0)
    {
        if (FD_ISSET(sockfd, &read_fd_set)) {
            [self readData];
        }
    }else if (result < 0)
    {
        MWLogDebug(@"select error: %@", strerror(errno));
    }
    
    return (result >= 0);
    
}



- (void)startListenerThreadIfNeeded
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        listenerThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(listenerThread)
                                                   object:nil];
        [listenerThread start];
    });
}

- (void)listenerThread
{
    
        [[NSThread currentThread] setName:UdpSocketThreadName];
        
        MWLogInfo(@"ListenerThread: Started");
        
        do{
            
            [self checkForIncomingPackets:10000];
            
            usleep(1000);
            
        }while(continue_loop);
        
        MWLogInfo(@"ListenerThread: Stopped");
    
        close(sockfd);
    
    
   
}



- (void)readData
// Called by the CFSocket read callback to actually read and process data
// from the socket.
{
    int                     err;
    struct sockaddr_storage addr;
    socklen_t               addrLen;
    
    ssize_t                 bytesRead;
    
    addrLen = sizeof(addr);
    bytesRead = recvfrom(self->sockfd, recv_buf, self.bufferSize, 0, (struct sockaddr *) &addr, &addrLen);
    if (bytesRead < 0) {
        err = errno;
    } else if (bytesRead == 0) {
        err = EPIPE;
    } else {
        NSData *    dataObj;
        NSData *    addrObj;
        
        err = 0;
        
        dataObj = [NSData dataWithBytes:recv_buf length:(NSUInteger) bytesRead];
        assert(dataObj != nil);
        addrObj = [NSData dataWithBytes:&addr  length:addrLen  ];
        assert(addrObj != nil);
        
        // Tell the delegate about the data.
        
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didReceiveData:fromAddress:)] ) {
            [self.delegate didReceiveData:dataObj fromAddress:addrObj];
        }
    }
    
    // If we got an error, tell the delegate.
    
    if (err != 0) {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didReceiveError:)] ) {
            [self.delegate didReceiveError:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
        }
    }
}



#if UDPCOMMS_IPV4_ONLY

- (BOOL)setupSocketConnectedToAddress:(NSData *)address port:(NSUInteger)port error:(NSError **)errorPtr
// Sets up the CFSocket in either client or server mode.  In client mode,
// address contains the address that the socket should be connected to.
// The address contains zero port number, so the port parameter is used instead.
// In server mode, address is nil and the socket is bound to the wildcard
// address on the specified port.
{
    int                     err;
    
    assert( (address == nil) == self.isServer );
    assert( (address == nil) || ([address length] <= sizeof(struct sockaddr_storage)) );
    assert(port < 65536);
    
    // Create the UDP socket itself.
    
    err = 0;
    self->sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    
    if (self->sockfd < 0) {
        err = errno;
    }
    
    
    // Bind or connect the socket, depending on whether we're in server or client mode.
    
    if (err == 0) {
        struct sockaddr_in      addr;
        
        memset(&addr, 0, sizeof(addr));
        if (address == nil) {
            // Server mode.  Set up the address based on the socket family of the socket
            // that we created, with the wildcard address and the caller-supplied port number.
            addr.sin_len         = sizeof(addr);
            addr.sin_family      = AF_INET;
            addr.sin_port        = htons(port);
            addr.sin_addr.s_addr = INADDR_ANY;
            err = bind(self->sockfd, (const struct sockaddr *) &addr, sizeof(addr));
        } else {
            // Client mode.  Set up the address on the caller-supplied address and port
            // number.
            if ([address length] > sizeof(addr)) {
                assert(NO);         // very weird
                [address getBytes:&addr length:sizeof(addr)];
            } else {
                [address getBytes:&addr length:[address length]];
            }
            assert(addr.sin_family == AF_INET);
            addr.sin_port = htons(port);
            err = connect(self->sockfd, (const struct sockaddr *) &addr, sizeof(addr));
        }
        if (err < 0) {
            err = errno;
        }
    }
    
    FD_ZERO (&read_fd_set);
    FD_SET (self->sockfd, &read_fd_set);
    
    
    
    return (err == 0);
}

#else   // ! UDPCOMMS_IPV4_ONLY

- (BOOL)setupSocketConnectedToAddress:(NSData *)address port:(NSUInteger)port error:(NSError **)errorPtr
// Sets up the CFSocket in either client or server mode.  In client mode,
// address contains the address that the socket should be connected to.
// The address contains zero port number, so the port parameter is used instead.
// In server mode, address is nil and the socket is bound to the wildcard
// address on the specified port.
{
    sa_family_t             socketFamily;
    int                     err;
    
    assert( (address == nil) == self.isServer );
    assert( (address == nil) || ([address length] <= sizeof(struct sockaddr_storage)) );
    assert(port < 65536);
    
    
    
    // Create the UDP socket itself.  First try IPv6 and, if that's not available, revert to IPv6.
    //
    // IMPORTANT: Even though we're using IPv6 by default, we can still work with IPv4 due to the
    // miracle of IPv4-mapped addresses.
    
    err = 0;
    self->sockfd = socket(AF_INET6, SOCK_DGRAM, 0);
    self->sendsock = socket(AF_INET6, SOCK_DGRAM, 0);
    if (self->sockfd >= 0) {
        socketFamily = AF_INET6;
    } else {
        self->sockfd = socket(AF_INET, SOCK_DGRAM, 0);
        self->sendsock = socket(AF_INET, SOCK_DGRAM, 0);
        if (self->sockfd >= 0) {
            socketFamily = AF_INET;
        } else {
            err = errno;
            socketFamily = 0;       // quietens a warning from the compiler
            assert(err != 0);       // Obvious, but it quietens a warning from the static analyser.
        }
    }
    
    // Bind or connect the socket, depending on whether we're in server or client mode.
    
    if (err == 0) {
        struct sockaddr_storage addr;
        struct sockaddr_in *    addr4;
        struct sockaddr_in6 *   addr6;
        
        addr4 = (struct sockaddr_in * ) &addr;
        addr6 = (struct sockaddr_in6 *) &addr;
        
        memset(&addr, 0, sizeof(addr));
        if (address == nil) {
            // Server mode.  Set up the address based on the socket family of the socket
            // that we created, with the wildcard address and the caller-supplied port number.
            addr.ss_family = socketFamily;
            if (socketFamily == AF_INET) {
                addr4->sin_len         = sizeof(*addr4);
                addr4->sin_port        = htons(port);
                addr4->sin_addr.s_addr = INADDR_ANY;
            } else {
                assert(socketFamily == AF_INET6);
                addr6->sin6_len         = sizeof(*addr6);
                addr6->sin6_port        = htons(port);
                addr6->sin6_addr        = in6addr_any;
            }
        } else {
            // Client mode.  Set up the address on the caller-supplied address and port
            // number.  Also, if the address is IPv4 and we created an IPv6 socket,
            // convert the address to an IPv4-mapped address.
            if ([address length] > sizeof(addr)) {
                assert(NO);         // very weird
                [address getBytes:&addr length:sizeof(addr)];
            } else {
                [address getBytes:&addr length:[address length]];
            }
            if (addr.ss_family == AF_INET) {
                if (socketFamily == AF_INET6) {
                    struct	in_addr ipv4Addr;
                    
                    // Convert IPv4 address to IPv4-mapped-into-IPv6 address.
                    
                    ipv4Addr = addr4->sin_addr;
                    
                    addr6->sin6_len         = sizeof(*addr6);
                    addr6->sin6_family      = AF_INET6;
                    addr6->sin6_port        = htons(port);
                    addr6->sin6_addr.__u6_addr.__u6_addr32[0] = 0;
                    addr6->sin6_addr.__u6_addr.__u6_addr32[1] = 0;
                    addr6->sin6_addr.__u6_addr.__u6_addr16[4] = 0;
                    addr6->sin6_addr.__u6_addr.__u6_addr16[5] = 0xffff;
                    addr6->sin6_addr.__u6_addr.__u6_addr32[3] = ipv4Addr.s_addr;
                } else {
                    addr4->sin_port = htons(port);
                }
            } else {
                assert(addr.ss_family == AF_INET6);
                addr6->sin6_port        = htons(port);
            }
            if ( (addr.ss_family == AF_INET) && (socketFamily == AF_INET6) ) {
                addr6->sin6_len         = sizeof(*addr6);
                addr6->sin6_port        = htons(port);
                addr6->sin6_addr        = in6addr_any;
            }
        }
        if (address == nil) {
            err = bind(self->sockfd, (const struct sockaddr *) &addr, addr.ss_len);
        } else {
            err = connect(self->sockfd, (const struct sockaddr *) &addr, addr.ss_len);
            err = connect(self->sendsock, (const struct sockaddr *) &addr, addr.ss_len);
        }
        if (err < 0) {
            err = errno;
        }
        
        // set up listening thread
        FD_ZERO (&read_fd_set);
        FD_SET (self->sockfd, &read_fd_set);
        
    }
    return (err == 0);
}

#endif  // ! UDPECHO_IPV4_ONLY



- (void)startServerOnPort:(NSUInteger)port
// See comment in header.
{
    assert( (port > 0) && (port < 65536) );
    
    assert(self.port == 0);     // don't try and start a started object
    if (self.port == 0) {
        BOOL        success;
        NSError *   error;
        
        // Create a fully configured socket.
        
        success = [self setupSocketConnectedToAddress:nil port:port error:&error];
        
        // If we can create the socket, we're good to go.  Otherwise, we report an error
        // to the delegate.
        
        if (success) {
            self.port = port;
            
            if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didStartWithAddress:)] ) {
                //CFDataRef   localAddress;
                
                //                localAddress = CFSocketCopyAddress(self->_cfSocket);
                //                assert(localAddress != NULL);
                //
                //                [self.delegate didStartWithAddress:(__bridge NSData *) localAddress];
                //
                //                CFRelease(localAddress);
                
                [self startListenerThreadIfNeeded];
            }
        } else {
            [self stopWithError:error];
        }
    }
}

- (void)hostResolutionDone
// Called by our CFHost resolution callback (HostResolveCallback) when host
// resolution is complete.  We find the best IP address and create a socket
// connected to that.
{
    NSError *           error;
    Boolean             resolved;
    NSArray *           resolvedAddresses;
    
    
    assert(self.port != 0);
    assert(self->_cfHost != NULL);
    assert(self.hostAddress == nil);
    
    error = nil;
    
    // Walk through the resolved addresses looking for one that we can work with.
    
    resolvedAddresses = (__bridge NSArray *) CFHostGetAddressing(self->_cfHost, &resolved);
    if ( resolved && (resolvedAddresses != nil) ) {
        for (NSData * address in resolvedAddresses) {
            BOOL                    success;
            const struct sockaddr * addrPtr;
            NSUInteger              addrLen;
            
            addrPtr = (const struct sockaddr *) [address bytes];
            addrLen = [address length];
            assert(addrLen >= sizeof(struct sockaddr));
            
            // Try to create a connected socket for this address.  If that fails,
            // we move along to the next address.  If it succeeds, we're done.
            
            success = NO;
            if (
                (addrPtr->sa_family == AF_INET)
#if ! UDPECHO_IPV4_ONLY
                || (addrPtr->sa_family == AF_INET6)
#endif
                ) {
                success = [self setupSocketConnectedToAddress:address port:self.port error:&error];
                if (success) {
                    
                    self.hostAddress =  [NSData dataWithData:address];
                }
            }
            if (success) {
                break;
            }
        }
    }
    
    // If we didn't get an address and didn't get an error, synthesise a host not found error.
    
    if ( (self.hostAddress == nil) && (error == nil) ) {
        error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorHostNotFound userInfo:nil];
    }
    
    if (error == nil) {
        // We're done resolving, so shut that down.
        
        [self stopHostResolution];
        
        // Tell the delegate that we're up.
        
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didStartWithAddress:)] ) {
            [self.delegate didStartWithAddress:self.hostAddress];
        }
    } else {
        [self stopWithError:error];
    }}

static void HostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
// This C routine is called by CFHost when the host resolution is complete.
// It just redirects the call to the appropriate Objective-C method.
{
    UDPEndpoint *    obj;
    
    obj = (__bridge UDPEndpoint *) info;
    assert([obj isKindOfClass:[UDPEndpoint class]]);
    
#pragma unused(theHost)
    assert(theHost == obj->_cfHost);
#pragma unused(typeInfo)
    assert(typeInfo == kCFHostAddresses);
    
    if ( (error != NULL) && (error->domain != 0) ) {
        [obj stopWithStreamError:*error];
    } else {
        [obj hostResolutionDone];
    }
}

- (void)startConnectedToHostName:(NSString *)hostName port:(NSUInteger)port
// See comment in header.
{
    assert(hostName != nil);
    assert( (port > 0) && (port < 65536) );
    
    assert(self.port == 0);     // don't try and start a started object
    if (self.port == 0) {
        Boolean             success;
        CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFStreamError       streamError;
        
        assert(self->_cfHost == NULL);
        
        self->_cfHost = CFHostCreateWithName(NULL, (__bridge CFStringRef) hostName);
        assert(self->_cfHost != NULL);
        
        CFHostSetClient(self->_cfHost, HostResolveCallback, &context);
        
        CFHostScheduleWithRunLoop(self->_cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        success = CFHostStartInfoResolution(self->_cfHost, kCFHostAddresses, &streamError);
        if (success) {
            self.hostName = hostName;
            self.port = port;
            // ... continue in HostResolveCallback
        } else {
            [self stopWithStreamError:streamError];
        }
    }
}

- (void)sendData:(NSData *)data
// See comment in header.
{
    // If you call -sendData: on a object in server mode or an object in client mode
    // that's not fully set up (hostAddress is nil), we just ignore you.
    if (self.isServer || (self.hostAddress == nil) ) {
        assert(NO);
    } else {
        [self sendData:data toAddress:nil];
    }
}

- (void)stopHostResolution
// Called to stop the CFHost part of the object, if it's still running.
{
    if (self->_cfHost != NULL) {
        CFHostSetClient(self->_cfHost, NULL, NULL);
        CFHostCancelInfoResolution(self->_cfHost, kCFHostAddresses);
        CFHostUnscheduleFromRunLoop(self->_cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(self->_cfHost);
        self->_cfHost = NULL;
    }
}

- (void)stop
// See comment in header.
{
    self.hostName = nil;
    self.hostAddress = nil;
    self.port = 0;
    continue_loop = NO;
    //[self stopHostResolution];
    //    if (self->_cfSocket != NULL) {
    //        CFSocketInvalidate(self->_cfSocket);
    //        CFRelease(self->_cfSocket);
    //        self->_cfSocket = NULL;
    //    }
    
    if (!listenerThread)
        close(sockfd);
}

- (void)noop
{
}

- (void)stopWithError:(NSError *)error
// Stops the object, reporting the supplied error to the delegate.
{
    assert(error != nil);
    [self stop];
    if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(didStopWithError:)] ) {
        // The following line ensures that we don't get deallocated until the next time around the
        // run loop.  This is important if our delegate holds the last reference to us and
        // this callback causes it to release that reference.  At that point our object (self) gets
        // deallocated, which causes problems if any of the routines that called us reference self.
        // We prevent this problem by performing a no-op method on ourself, which keeps self alive
        // until the perform occurs.
        [self performSelector:@selector(noop) withObject:nil afterDelay:0.0];
        [self.delegate didStopWithError:error];
    }
}

- (void)stopWithStreamError:(CFStreamError)streamError
// Stops the object, reporting the supplied error to the delegate.
{
    NSDictionary *  userInfo;
    NSError *       error;
    
    if (streamError.domain == kCFStreamErrorDomainNetDB) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInteger:streamError.error], kCFGetAddrInfoFailureKey,
                    nil
                    ];
    } else {
        userInfo = nil;
    }
    error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorUnknown userInfo:userInfo];
    assert(error != nil);
    
    [self stopWithError:error];
}

@end
