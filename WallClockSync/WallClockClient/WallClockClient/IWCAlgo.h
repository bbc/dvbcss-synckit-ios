//
//  IWCAlgo.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Candidate.h"


/** Protocol for Wall Clock Client algorithms*/
@protocol IWCAlgo <NSObject>

@required
///-----------------------------------------------------------
/// @name Required methods
///-----------------------------------------------------------

/** process this candidate measurement
 @param candidate a new candidate measurement
 @return the current offset
 */
- (int64_t) processMeasurement:(Candidate*) candidate;

/**
 *  get best dispersion at current time
 *
 *  @return best dispersion value at current time
 */
- (int64_t) getCurrentDispersion;


/**
 *  get best offset in nanoseconds
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


/**
 *  Get wait time for next request. Based of the dispersion value of the last candidate, 
 *  the WC algorithm (i.e. an object implementing IWCAlgo interface) sets the send time for the next
 *  WC request. 
 *
 *  @return wait time in micro-seconds.
 */
- (uint32_t) getNextReqWaitTime;



@optional
///-----------------------------------------------------------
/// @name Optional methods
///-----------------------------------------------------------
/**
 *  Time between candidates that caused a WallClock time adjustment
 *
 *  @return time in nanoseconds
 */
- (int64_t) timeBetweenUsefulCandidatesNanos;


/**
 *  Get the percentage of candidate measurements that led to a wallclock time readjustment.
 *
 *  @return percentage of useful candidate measurements
 */
- (float) usefulCandidatesPercent;



@end
