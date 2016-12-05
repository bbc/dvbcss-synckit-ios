//
//  WCMeasurementsCollector.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 13/08/2014.
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
#import <UDPMessaging/UDPMessaging.h>
#import <ClockTimelines/ClockTimelines.h> 

#import "Candidate.h"
#import "ICandidateHandler.h"


/**
 *  A class implementing the client-side (Companion app) functionality of the DVB-CSS WallClock protocol. 
 *  This client reads time values from the wall clock and uses it to initialise a WallClock protocol request
 *  message before sending the message to the WallClock server. Upon reception
 *  of the WallClock response, it creates a Candidate measurement object which is then passed on to the CandidateSink
 *  object for further processing.
 *
 *  The CandidateSink object reads candidate measurements, calculate the wallclock offset (between the protocol 
 *  client's wallclock and the protocol server's wallclock) and readjusts the local wallclock with the offset.
 *  With this approach, the WallClockClient component, uses a feedback loop to submit new originate_timevalue
 *  timestamps, calculate the wallclock offset and readjust the WallClock time based on this offset.
 *
 */
@interface WCProtocolClient : NSObject <UDPCommsDelegate>

/** wall clock server host name*/
@property (nonatomic, copy,   readwrite) NSString *    hostName;

/** resolved host address from host name*/
@property (nonatomic, copy,   readwrite) NSData *      hostAddress;

/**
 *  Wallclock server port
 */
@property (nonatomic, assign, readwrite) NSUInteger    port;

/**
 *  A candidate measurement processing object
 */
@property (atomic, readwrite) id<ICandidateHandler>    candidateSink;

/**
 *  A reference to a wallclock to use for originate_time and response_time timestamps
 */
@property (atomic, readonly) ClockBase*                wallclockRef;

/** running status of this component   */
@property (atomic, readonly, getter = isRunning) BOOL  running;

/** limit on messages per second this component can emit */
@property (atomic, readonly) uint32_t                   ratelimit;

/** WC Synchronisation request wait time in milliseconds*/
@property (atomic, readonly) uint32_t                   requestWaitTime;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initialise a WallClock protocol client instance
 *
 *  @param hostname - DNS-resolvable hostname of the machine running the Wall Clock server (e.g. a DVB-TV)
 *  @param port     - port WallClock server is configured to listen to
 *  @param can_sink - a handler for candidate measurements. WCClient will enqueue candidate measurements
 *  @param clock    - a clock to use for getting timestamps and calculating offsets, e.g. the local WallClock instance
 *
 *  @return an WCClient instance.
 */
- (id) initWithHost:(NSString*) hostname Port:(NSUInteger) port CandidateSink:(id<ICandidateHandler>) can_sink AndWallClock:(ClockBase*) clock;


/**
 *  Start WallClock sync measurement collection session. Starts the emission of WC protocol request messages.
 */
- (void) start;



/**
 *  Stop the WallClock sync. This stops the emission of new WallClock protocol request messages
 */
- (void) stop;


@end






