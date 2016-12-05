//
//  UDPEndpoint.h
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


#import <Foundation/Foundation.h>
#import "UDPCommsDelegate.h"
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <CFNetwork/CFNetwork.h>
#else
#import <CoreServices/CoreServices.h>
#endif
#import <stdlib.h>



/**
 A class to represent a communications endpoint based on UDP sockets. IPv4/IPv6
 are both supported. A UDPEndpoint enables a UDP server to be started by binding 
 the underlying socket to a specified port and provides a method to be scheduled for 
 checking for incoming packets. In client mode, a socket is created to target a remote 
 address and port. Data packets can then be sent to the remote UDP endpoint by calling
 -sendData:.
  */
@interface UDPEndpoint : NSObject


/**
 *  Unused default initialiser
 *
 *  @return initialised UDPEndpoint instance
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initialise a UDPEndpoint instance with a buffer size
 *
 *  @param size buffer size e.g. size of protocol message
 *
 *  @return initialised UDPEndpoint instance
 */
- (id)initWithBufferSize:(size_t) size;

/**
 *   Starts a server on the specified port.  Will call the
 -echo:didStartWithAddress: delegate method on success and the
 -echo:didStopWithError: on failure.  After that, the various
 'data' delegate methods may be called.
 *
 *  @param port an available local port
 */
- (void)startServerOnPort:(NSUInteger)port;

/**
 *   Starts a client targetting the specified host and port.
 Will call -echo:didStartWithAddress: delegate method on success and
 the -echo:didStopWithError: on failure.  At that point you can call
 -sendData: to send data to the server and the various 'data' delegate
 methods may be called.

 *
 *  @param hostName remote host address ()
 *  @param port     remote port to be targetted
 */
- (void)startConnectedToHostName:(NSString *)hostName port:(NSUInteger)port;

/**
 *   On the client, sends the specified data to the server.  The
 -echo:didSendData:toAddress: or -echo:didFailToSendData:toAddress:error:
 delegate method will be called to indicate the success or failure
 of the send, and the -echo:didReceiveData:fromAddress: delegate method
 will be called if a response is received.

 *
 *  @param data bytes to be sent
 */
- (void)sendData:(NSData *)data;

/**
 *   Will stop the object, preventing any future network operations or delegate
 method calls until the next start call.

 */
- (void)stop;

/**
 *  Get buffer used for sending
 *
 *  @return pointer to send buffer
 */
- (uint8_t *) getSendBuffer;

/**
 *  Get buffer used for receiving
 *
 *  @return pointer to receive buffer
 */
- (uint8_t *) getReceiveBuffer;

/**
 *  Method to check if packets are available . This method can be called periodically on a separate thread.
 *
 *  @param timeout_us timeout for select call to block when waiting for on socket descriptor to become ready for reading
 *
 *  @return true if select call did not return an error
 */
- (BOOL) checkForIncomingPackets:(uint32_t) timeout_us;

/**
 *  Start a listener thread to check for incoming packets.
 */
- (void)startListenerThreadIfNeeded;

/**
 *  A delegate that is notified about new packet arrival, packet send success, etc
 */
@property (nonatomic, weak,   readwrite) id<UDPCommsDelegate>    delegate;

/**
 *  Is UDPEndpoint running in server mode?
 */
@property (nonatomic, assign, readonly, getter=isServer) BOOL   server;

/**
 * Name of remote host targetted for sending data. Property value only valid in client mode.
 */
@property (nonatomic, copy,   readonly ) NSString *             hostName;       //

/**
 *  Address of remote host targetted for sending data. Property value only valid in client mode after successful start.
 */
@property (nonatomic, copy,   readonly ) NSData *               hostAddress;    // valid in client mode after successful start

/**
 *   Remote host's port number targetted for sending data. Property value only valid in client mode
 */
@property (nonatomic, assign, readonly ) NSUInteger             port;


@end
