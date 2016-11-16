//
//  UDPComms.h
//  WallClockSyncTestServer
//
//  Created by Rajiv Ramdhany on 24/07/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <CFNetwork/CFNetwork.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@protocol UDPCommsDelegate;

@interface UDPComms : NSObject

- (id)init;

- (void)startServerOnPort:(NSUInteger)port;
// Starts a server on the specified port.  Will call the
// -echo:didStartWithAddress: delegate method on success and the
// -echo:didStopWithError: on failure.  After that, the various
// 'data' delegate methods may be called.

- (void)startConnectedToHostName:(NSString *)hostName port:(NSUInteger)port;
// Starts a client targetting the specified host and port.
// Will call -echo:didStartWithAddress: delegate method on success and
// the -echo:didStopWithError: on failure.  At that point you can call
// -sendData: to send data to the server and the various 'data' delegate
// methods may be called.

- (void)sendData:(NSData *)data;
// On the client, sends the specified data to the server.  The
// -echo:didSendData:toAddress: or -echo:didFailToSendData:toAddress:error:
// delegate method will be called to indicate the success or failure
// of the send, and the -echo:didReceiveData:fromAddress: delegate method
// will be called if a response is received.

- (void)stop;
// Will stop the object, preventing any future network operations or delegate
// method calls until the next start call.

@property (nonatomic, weak,   readwrite) id<UDPCommsDelegate>    delegate;
@property (nonatomic, assign, readonly, getter=isServer) BOOL   server;
@property (nonatomic, copy,   readonly ) NSString *             hostName;       // valid in client mode
@property (nonatomic, copy,   readonly ) NSData *               hostAddress;    // valid in client mode after successful start
@property (nonatomic, assign, readonly ) NSUInteger             port;           // valid in client and server mode


@end

@protocol UDPCommsDelegate <NSObject>

@optional

// In all cases an address is an NSData containing some form of (struct sockaddr),
// specifically a (struct sockaddr_in) or (struct sockaddr_in6).

- (void) didReceiveData:(NSData *)data fromAddress:(NSData *)addr;
// Called after successfully receiving data.  On a server object this data will
// automatically be echoed back to the sender.


- (void) didReceiveError:(NSError *)error;
// Called after a failure to receive data.


- (void) didSendData:(NSData *)data toAddress:(NSData *)addr;
// Called after successfully sending data.

- (void) didFailToSendData:(NSData *)data toAddress:(NSData *)addr error:(NSError *)error;
// Called after a failure to send data.


- (void) didStartWithAddress:(NSData *)address;
// Called after the object has successfully started up.  On the client addresses
// is the list of addresses associated with the host name passed to
// -startConnectedToHostName:port:.  On the server, this is the local address
// to which the server is bound.


- (void) didStopWithError:(NSError *)error;
// Called after the object stops spontaneously (that is, after some sort of failure,
// but now after a call to -stop).


@end
