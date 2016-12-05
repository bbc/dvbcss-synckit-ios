//
//  ViewController.m
//  WallClockSyncProtoClient
//
//  Created by Rajiv Ramdhany on 24/07/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UDPMessaging/UDPMessaging.h>
#import "ViewController.h"

#include <netdb.h>


#pragma mark * Utilities

static NSString * DisplayAddressForAddress(NSData * address)
// Returns a dotted decimal string for the specified address (a (struct sockaddr)
// within the address NSData).
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    char        servStr[NI_MAXSERV];
    
    result = nil;
    
    if (address != nil) {
        
        // If it's a IPv4 address embedded in an IPv6 address, just bring it as an IPv4
        // address.  Remember, this is about display, not functionality, and users don't
        // want to see mapped addresses.
        
        if ([address length] >= sizeof(struct sockaddr_in6)) {
            const struct sockaddr_in6 * addr6Ptr;
            
            addr6Ptr = [address bytes];
            if (addr6Ptr->sin6_family == AF_INET6) {
                if ( IN6_IS_ADDR_V4MAPPED(&addr6Ptr->sin6_addr) || IN6_IS_ADDR_V4COMPAT(&addr6Ptr->sin6_addr) ) {
                    struct sockaddr_in  addr4;
                    
                    memset(&addr4, 0, sizeof(addr4));
                    addr4.sin_len         = sizeof(addr4);
                    addr4.sin_family      = AF_INET;
                    addr4.sin_port        = addr6Ptr->sin6_port;
                    addr4.sin_addr.s_addr = addr6Ptr->sin6_addr.__u6_addr.__u6_addr32[3];
                    address = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
                    assert(address != nil);
                }
            }
        }
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), servStr, sizeof(servStr), NI_NUMERICHOST | NI_NUMERICSERV);
        if (err == 0) {
            result = [NSString stringWithFormat:@"%s:%s", hostStr, servStr];
            assert(result != nil);
        }
    }
    
    return result;
}

static NSString * DisplayStringFromData(NSData *data)
// Returns a human readable string for the given data.
{
    NSMutableString *   result;
    NSUInteger          dataLength;
    NSUInteger          dataIndex;
    const uint8_t *     dataBytes;
    
    assert(data != nil);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    result = [NSMutableString stringWithCapacity:dataLength];
    assert(result != nil);
    
    [result appendString:@"\""];
    for (dataIndex = 0; dataIndex < dataLength; dataIndex++) {
        uint8_t     ch;
        
        ch = dataBytes[dataIndex];
        if (ch == 10) {
            [result appendString:@"\n"];
        } else if (ch == 13) {
            [result appendString:@"\r"];
        } else if (ch == '"') {
            [result appendString:@"\\\""];
        } else if (ch == '\\') {
            [result appendString:@"\\\\"];
        } else if ( (ch >= ' ') && (ch < 127) ) {
            [result appendFormat:@"%c", (int) ch];
        } else {
            [result appendFormat:@"\\x%02x", (unsigned int) ch];
        }
    }
    [result appendString:@"\""];
    
    return result;
}

static NSString * DisplayErrorFromError(NSError *error)
// Given an NSError, returns a short error string that we can print, handling
// some special cases along the way.
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    assert(error != nil);
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) ) {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = [NSString stringWithUTF8String:failureStr];
                    assert(result != nil);
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    assert(result != nil);
    return result;
}



@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *serverTextField;
@property (strong, nonatomic) IBOutlet UITextView *outputTextView;

@property (nonatomic, strong, readwrite) UDPEndpoint *    udpcomms;
@property (nonatomic, strong, readwrite) NSTimer *      sendTimer;
@property (nonatomic, assign, readwrite) NSUInteger     sendCount;

- (IBAction)testButtonClicked:(id)sender;


@end


typedef struct __attribute__((packed)){
    uint8_t version;
    uint32_t time_value;
}Message;




@implementation ViewController
{
    NSThread* recvThr;

}

@synthesize serverTextField = _serverTextField;
@synthesize outputTextView = _outputTextView;
@synthesize udpcomms  = _udpcomms;
@synthesize sendTimer = _sendTimer;
@synthesize sendCount = _sendCount;


- (void)dealloc
{
    [_udpcomms stop];
    [self->_sendTimer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    recvThr =   [[NSThread alloc]
                             initWithTarget:self
                             selector:@selector(recvThrFunc)
                             object:nil];
    _serverTextField.text = @"server_IP:port";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testButtonClicked:(id)sender {
	    
    BOOL                success;
    
    NSArray<NSString*> *temp = [_serverTextField.text componentsSeparatedByString:@":"];
    
    NSString* hostname = [temp objectAtIndex:0];
    NSUInteger port = (NSUInteger) [[temp objectAtIndex:1] integerValue];
    
    success =  [self runClientWithHost: hostname port:port ];
}


- (BOOL)runClientWithHost:(NSString *)host port:(NSUInteger)port
// One of two Objective-C 'mains' for this program.  This creates a UDPComms
// object in client mode, talking to the specified host and port, and then
// periodically sends packets via that object.
{
    assert(host != nil);
    assert( (port > 0) && (port < 65536) );
    
    assert(self.udpcomms == nil);
    
    self.udpcomms = [[UDPEndpoint alloc] initWithBufferSize:65536];
    assert(self.udpcomms != nil);
    
    self.udpcomms.delegate = self;
    
    [self.udpcomms startConnectedToHostName:host port:port];
    
    while (self.udpcomms != nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    // The loop above is supposed to run forever.  If it doesn't, something must
    // have failed and we want main to return EXIT_FAILURE.
    
    return NO;
}

- (void)sendPacket
// Called by the client code to send a UDP packet.  This is called immediately
// after the client has 'connected', and periodically after that from the send
// timer.
{
    NSData *    data;
    
    assert(self.udpcomms != nil);
    assert( ! self.udpcomms.isServer );
    
    data = [[NSString stringWithFormat:@"%lu bottles of beer on the wall", (99 - self.sendCount)] dataUsingEncoding:NSUTF8StringEncoding];
    assert(data != nil);
    
    [self.udpcomms sendData:data];
    
    self.sendCount += 1;
    if (self.sendCount > 99) {
        self.sendCount = 0;
    }
}

- (void) didReceiveData:(NSData *)data fromAddress:(NSData *)addr
// This UDPComms delegate method is called after successfully receiving data.
{
    assert(data != nil);
    assert(addr != nil);
    NSLog(@"received %@ from %@", DisplayStringFromData(data), DisplayAddressForAddress(addr));
    
    dispatch_async(dispatch_get_main_queue(), ^{
    _outputTextView. text = [_outputTextView.text stringByAppendingString:[NSString stringWithFormat:@"received %@ from %@\n", DisplayStringFromData(data), DisplayAddressForAddress(addr)]];
    });


}

- (void) didReceiveError:(NSError *)error
// This UDPComms delegate method is called after a failure to receive data.
{
    assert(error != nil);
    NSLog(@"received error: %@", DisplayErrorFromError(error));
}

- (void) didSendData:(NSData *)data toAddress:(NSData *)addr
// This UDPComms delegate method is called after successfully sending data.
{
    assert(data != nil);
    assert(addr != nil);
    NSLog(@" \t sent %@ to   %@", DisplayStringFromData(data), DisplayAddressForAddress(addr));
    
    _outputTextView. text = [_outputTextView.text stringByAppendingString:[NSString stringWithFormat:@"sent %@ to %@\n", DisplayStringFromData(data), DisplayAddressForAddress(addr)]];
}

- (void) didFailToSendData:(NSData *)data toAddress:(NSData *)addr error:(NSError *)error
// This UDPComms delegate method is called after a failure to send data.
{
    assert(data != nil);
    assert(addr != nil);
    assert(error != nil);
    NSLog(@" sending %@ to   %@, error: %@", DisplayStringFromData(data), DisplayAddressForAddress(addr), DisplayErrorFromError(error));
}

- (void) didStartWithAddress:(NSData *)address
// This UDPComms delegate method is called after the object has successfully started up.
{
    assert(address != nil);
    
    if (self.udpcomms.isServer) {
        NSLog(@"receiving on %@", DisplayAddressForAddress(address));
    } else {
        NSLog(@"sending to %@", DisplayAddressForAddress(address));
    }
    
    [recvThr start];
    
    if ( ! self.udpcomms.isServer ) {
        [self sendPacket];
        
        assert(self.sendTimer == nil);
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPacket) userInfo:nil repeats:YES];
    }
}

- (void) didStopWithError:(NSError *)error
// This UDPComms delegate method is called  after the object stops spontaneously.
{
    
    assert(error != nil);
    NSLog(@"failed with error: %@", DisplayErrorFromError(error));
    self.udpcomms = nil;
}

-(void) recvThrFunc
{
    
    while (true) {
        
        [_udpcomms checkForIncomingPackets:1000000];
        
        usleep(1000);
    }
    
    
    
}

@end
