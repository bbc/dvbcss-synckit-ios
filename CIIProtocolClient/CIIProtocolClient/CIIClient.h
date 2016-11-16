//
//  CII.h
//  
//
//  Created by Rajiv Ramdhany on 09/10/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
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
#import <SocketRocketiOS/SocketRocketiOS.h>
#import "CII.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

/**
 *  CII status bitmask
 */
typedef enum: NSUInteger
{
    NewCIIReceived              = (1 << 0),
    MRSUrlChanged               = (1 << 1),
    ContentIdChanged            = (1 << 2),
    ContentIdStatusChanged      = (1 << 3),
    PresentationStatusChanged   = (1 << 4),
    WCSUrlChanged               = (1 << 5),
    TSSUrlChanged               = (1 << 6),
    TimelineSelectorChanged     = (1 << 7),
    TimelinesChanged            = (1 << 8),
}CIIChangeStatus;


//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------
extern NSString * const kCIIConnectionFailure;
extern NSString * const kCIIDidChange;

//------------------------------------------------------------------------------
#pragma mark - Bitmask
//------------------------------------------------------------------------------
extern NSString * const kCIIChangeStatusMask;


//------------------------------------------------------------------------------
#pragma mark - CIIClient
//------------------------------------------------------------------------------
/**
 *  The CII Protocol Client class for receiving CII state updates from the TV.
 *  It uses the InterDevSyncURL from a discovered TV (via DIAL; See DIALDevice class in DIALDeviceDiscovery component)
 *  to make a websocket connection with the CII protocol server running on the TV.
 *  
 *  CII messages when received are classified as a new unseen message (the first CII message from a newly discovered TV) 
 *  or as an update. Events are produced to notify observers about a new CII or the field(s) that were updated in the CII
 *  message. The events report changes to the CII state by sending a copy of the CII object and a CIIChangeStatus bitmask
 *  for identifying the fields in the state that were changed in the last CII protocol message.
 *
 *  Please note that this CII Protocol Client implementation acts an endpoint to only one CII server. i.e. only
 *  one CII object is maintained.
 *
 *  ------------------------------------------------------------------------------
 *  Events produced = {CIIConnectionFailure, CIIDidChange}
 *  Events required = None.
 *  ------------------------------------------------------------------------------
 *
 */
@interface CIIClient : NSObject <SRWebSocketDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  CII protocol server endpoint URL. Readonly.
 */
@property (nonatomic, readonly) NSString* ciiUrl;

/**
 *  CII state maintained by this CII protocol client.
 */
@property (nonatomic, readonly) CII* ciiInstance;

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

/**
 *  Initialise a CIIClient object during instantiation.
 *
 *  @param cii_url CII server endpoint URL
 *
 *  @return CIIClient instance
 */
- (id) initWithCIIURL:(NSString*) cii_url;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Start the CII protocol client.
 */
- (void) start;

/**
 *  Pause the CII protocol client. To restart, call start method.
 */
- (void) pause;

/**
 *  Stop the CII protocol client.
 */
- (void) stop;

//------------------------------------------------------------------------------
@end



