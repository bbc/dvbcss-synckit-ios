//
//  CandidateM.h
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
#import "WCSyncMessage.h"
#import <SyncKitCollections/SyncKitCollections.h>


/**
 
 A class for candidate measurement objects. Each candidate has a
 dispersion associated with it. This dispersion increases with time.
 If at a particular time T, the candidate's dispersion > MAX_TOLERABLE_DISPERSION, then the candidate is no longer useful
 and should be filtered out.
 */
@interface Candidate : Node

/** T1 */
@property (nonatomic, readwrite) int64_t           originateTime;  // T1
/** T2 */
@property (nonatomic, readwrite) int64_t           receiveTime;    // T2
/** T3 */
@property (nonatomic, readwrite) int64_t           transmitTime;   // T3
/** T4 */
@property (nonatomic, readwrite) int64_t           responseTime;   // T4
/** Time values in nanos or ticks */
@property (nonatomic, readwrite, getter = isNanos) BOOL nanos;
/** computed candidate offset */
@property (nonatomic, readwrite) int64_t           offset;
/** computed candidate RTT */
@property (nonatomic, readwrite) int64_t           RTT;
/** WC Server Precision in ppm */
@property (nonatomic, readwrite) int64_t           wcServerPrecisionInNanos; // in nanos
/** WC Server maximum frequency error */
@property (nonatomic, readwrite) uint32_t           wcServerMaxFreqError;
/** From-the-wire WC Server response message */
@property (nonatomic, readwrite) WCSyncMessage      *responseMsg;
/** quality of measurement, is it a followup? */
@property (nonatomic, readwrite) int8_t            quality;

@property (nonatomic, readwrite) int64_t          initialDispersion;

/**
 *  Initialise a candidate object with a received WC Sync packet and calculate initial dispersion
 *  @param response_msg a WCSyncMessage response received from the Wall Clock server
 *  @param quality the quality of the response
 *  @param is_nanos Boolean flag, true if time is in nano seconds.
 */
- (id)initWithResponseMsg:(WCSyncMessage*) response_msg Quality: (int8_t) quality TimeIsNanos:(BOOL) is_nanos;


/**
 *  Compute and return candidate offset
 *
 *  @return candidate offset in nanoseconds
 */
- (int64_t) getOffset;


/**
 *  Compute and return candidate round trip time
 *
 *  @return RTT in nanoseconds
 */
- (int64_t) getRTT;

/** 
 *  Compute and return dispersion for candidate offset at a particular time instant
 *  @param time current time in nanoseconds
 */
- (int64_t) getDispersionAtTime:(int64_t) time;


/** 
 *  Returns the time in nanoseconds after which candidate measurement will be
 *  greater than the maximum tolerable dispersion
 *  @param accuracy_target_nanos Maximum tolerable dispersion to achieve wall clock synchronisation
 *  of desired accuracy
 */
- (int64_t) getCandidateExpirationTime:(int64_t) accuracy_target_nanos;

@end
