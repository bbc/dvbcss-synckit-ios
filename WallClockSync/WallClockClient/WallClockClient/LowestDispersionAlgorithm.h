//
//  LowestDispersionAlgorithm.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWCAlgo.h"
#import <ClockTimelines/ClockTimelines.h>


/**
 *  Algorithm that selects the candidate (request-response measurement result) with the lowest
 *  dispersion.
 *
 *  Dispersion is a formal measure of the error bounds of the Wall Clock estimate. This value is the 
 *  sum of possible error due to:
 *
 *      - measurement precision limitations (at both client and server)
 *      - round-trip time
 *      - maximum potential for oscillator frequency error at the client and at the server server
 *  This grows as the candidate (that was used to most recently adjust the clock) ages.
 *
 *  Note: The Clock object must be the same one that is provided to the WallClockClient,
 *  otherwise this algorithm will not synchronise correctly.
 *
 *  The tick rate of the Clock can be any tick rate (it does not have to be one tick per
 *  nanosecond), but too low a tick rate will limit clock synchronisation precision.
 *
 */
@interface LowestDispersionAlgorithm : NSObject <IWCAlgo>

/**
 *  Candidate with lowest dispersion
 */
@property (nonatomic, readonly) Candidate* bestCandidate;


- (instancetype)init NS_UNAVAILABLE;


/**
 *  Initialise algorithm
 *
 *  @param wall_clock - a clock whose tick offset can be adjusted.
 *
 *  @return Algorithm instance
 */
- (id)initWithWallClock:(TunableClock*) wall_clock;

@end
