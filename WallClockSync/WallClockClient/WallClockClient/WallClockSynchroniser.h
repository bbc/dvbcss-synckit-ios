//
//  WallClockClientComponent.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 12/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
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
#import "WCProtocolClient.h"
#import "CandidateSink.h"

/**
 *  A configurator component to setup all the sub-components for a WallClock time synchronisation.
 *
 *  To perform WallClock time synchronisation, the following components are required:
 *  
 *  1. A WallClock server's host address and port number
 * 
 *  2. A local WallClock that will be synchronised.In this implementation, the same WallClock in used to timestamp WC protocol
 *     messages.
 *
 *  3. A WC protocol client (WCProtocolClient object) to send WC requests and receive WC responses.
 *     On reception of WC response messages, the WCProtocolClient object creates a Candidate 
 *     measurement object and submits it to a CandidateSink object for further proccesing.
 *
 *  4. A Candidate measurement handler object of the type CandidateSink.
 *
 *  5. An algorithm object to process Candidates and readjust the local WallClock's offset. WC
 *     algorithms must conform to the IWCAlgo protocol.
 *
 *  6. A list of filters (IFilter-conforming instances) to reject unsuitable Candidates e.g. a
 *     candidates with an RTT that exceeds a specified threshold.
 *
 *  The WCProtocolClient and CandidateSink components are loaded by the configurator. The algorithm 
 *  and filter list have to be specified by the user when the configurator WallClockClientComponent 
 *  is initialised.
 */
@interface WallClockSynchroniser : NSObject


/** WallClock server's host address */
@property (nonatomic, readonly) NSString* WCServerHost;


/** WallClock server's  port number*/
@property (nonatomic, readonly) int port;

/**
 *  A reference to a WallClock that is used for timestamping WC request and response messages. The
 *  WallClock's offset is also adjusted by the CandidateSink's WC algorithm object when Candidate
 *  measurements are processed.
 */
@property (nonatomic, strong) TunableClock* wallClockRef;


/**
 *  A WCProtocolClient object for sending WC requests and generating Candidate measurements
 */
@property (nonatomic, strong, readonly) WCProtocolClient *wcProtoClient;

/**
 *  A component to process candidate measurements collected by the WCProtocolClient component
 *  and use an algorithm to calculate offset and dispersion value of the wallclock. If the candidate
 *  being processed is better than our best candidate (e.g. lower dispersion, lower RTT, etc), then the CandidateSink object readjusts
 */
@property (nonatomic, strong, readonly) CandidateSink *candidateHandler;

/**
 *  WC algorithm e.g. LowestDispersionAlgorithm to process candidates
 */
@property (nonatomic, strong, readonly) id<IWCAlgo> algorithm;

/**
 *  A list of filters to reject unsuitable candidates.
 */
@property (nonatomic,strong, readonly) NSArray *filters;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initialise the WallClockClientComponent, a configurator object for the WallClock time 
 *  synchronisation framework. A default algorithm (LowestDispersionAlgorithm) and a default 
 *  filter (RTTThresholdFilter) are loaded
 *
 *  @param address   - hostname or IP address of WallClock server host
 *  @param port      - port number of WallClock server
 *  @param wallclock - - a TunableClock instance serving as a local WallClock
 *
 *  @return  a WallClockClientComponent instance
 */
- (instancetype)initWithWCServer:(NSString *)address
                            Port:(int)port
                       WallClock:(TunableClock *)wallclock;

/**
 *  Initialise the WallClockClientComponent, a configurator object for the WallClock time synchronisation framework.
 *
 *  @param address   - hostname or IP address of WallClock server host
 *  @param port      - port number of WallClock server
 *  @param wallclock - a TunableClock instance serving as a local WallClock
 *  @param algorithm - A IWCAlgo protocol-conforming algorithm for processing Candidates
 *  @param filters   - List of filters. Each filter should conform to the IFilter protocol
 *
 *  @return a WallClockClientComponent instance
 */
- (instancetype) initWithWCServer:(NSString*) address
                   Port:(int) port
              WallClock:(TunableClock*) wallclock
              Algorithm:(id<IWCAlgo>) algo
             FilterList:(NSArray*) filters;

/**
 *  Start WallClock time synchronisation
 */
- (void) start;

/**
 * Pause WallClock time synchronisation. To restart, call start method
 */
- (void) pause;

/**
 *  Stop WallClock time synchronisation
 */
- (void) stop;


/**
 *  Get the percentage of bad candidate measurements i.e. candidates rejected by filters
 *
 *  @return percentage of bad candidate measurements
 */
- (float) getCandidatesDroppedPercent;


- (int64_t) getTimeBetweenUsefulCandidates;

/**
 *  Get the percentage of candidate measurements that led to a wallclock time readjustment.
 *
 *  @return percentage of useful candidate measurements
 */
- (float) getUsefulCandidatesPercent;


/**
 *  Get the current dispersion of the best candidate.
 *
 *  @return the currently best dispersion value in nanoseconds
 */
- (int64_t) getCurrentDispersion;


/**
 *  get best offset
 *
 *  @return get best candidate's offset
 */
- (int64_t) getCandidateOffset;



/**
 *  Get the current best candidate seen by the algorithm.
 *
 *  @return the current best candidate (a Candidate object)
 */
- (Candidate*) getBestCandidate;

@end
