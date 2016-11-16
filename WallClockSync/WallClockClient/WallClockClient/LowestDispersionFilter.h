//
//  LowestDispersionFilter.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Candidate.h"
#import "IFilter.h"


/**
 *  Simple filter that will reject a candidate unless its dispersion is lower than any candidate seen  previously.
 */
@interface LowestDispersionFilter : NSObject <IFilter>

/**
 *  the best candidate that passes the min and max
 */
@property (nonatomic, readonly) Candidate* bestCandidate;

/**
 *  A reference to a wallclock for calculating current dispersion of the best candidate
 */
@property (nonatomic, readonly, weak) ClockBase* wallclockRef;


- (instancetype)init NS_UNAVAILABLE;

@end
