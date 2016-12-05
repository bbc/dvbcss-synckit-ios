//
//  UDPCommsDelegate.h
//
//  Created by Rajiv Ramdhany on 17/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Callback methods for delegate  of a UDPEndpoint object.
 */
@protocol UDPCommsDelegate <NSObject>
@optional

// In all cases an address is an NSData containing some form of (struct sockaddr),
// specifically a (struct sockaddr_in) or (struct sockaddr_in6).

/**
 *  Called after successfully receiving data.  On a server object this data will
 *  automatically be echoed back to the sender.
 *
 *  @param data -   bytes received.
 *  @param addr -   an NSData containing some form of (struct sockaddr),
 *                  specifically a (struct sockaddr_in) or (struct sockaddr_in6)
 */
- (void) didReceiveData:(NSData *)data fromAddress:(NSData *)addr;


/**
 *  Called after a failure to receive data.
 *
 *  @param error -  error description
 */
- (void) didReceiveError:(NSError *)error;

/**
 *  Called after successfully sending data.
 *
 *  @param data -   bytes to send.
 *  @param addr -   an NSData containing some form of (struct sockaddr),
 *                  specifically a (struct sockaddr_in) or (struct sockaddr_in6)
 */
- (void) didSendData:(NSData *)data toAddress:(NSData *)addr;

/**
 *  Called after a failure to send data.
 *
 *  @param data -   bytes to send.
 *  @param addr -   an NSData containing some form of (struct sockaddr),
 *                  specifically a (struct sockaddr_in) or (struct sockaddr_in6)
 */
- (void) didFailToSendData:(NSData *)data toAddress:(NSData *)addr error:(NSError *)error;


/**
 *  Called after the object has successfully started up.  On the client addresses
 *  is the list of addresses associated with the host name passed to
 *  -startConnectedToHostName:port:.  On the server, this is the local address
 *  to which the server is bound.
 *
 *  @param address -    an NSData containing some form of (struct sockaddr) e.g.
 *                      a (struct sockaddr_in) or (struct sockaddr_in6)
 */
- (void) didStartWithAddress:(NSData *)address;


/**
 *  Called after the object stops spontaneously (that is, after some sort of failure,
 *  but now after a call to -stop).
 *
 *  @param error -  error description
 */
- (void) didStopWithError:(NSError *)error;
//
@end
