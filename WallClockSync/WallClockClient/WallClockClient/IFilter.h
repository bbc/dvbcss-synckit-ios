//
//  IFilter.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Candidate.h"

/**
 *  Protocol defines methods for Candidate filters
 */
@protocol IFilter <NSObject>

/**
 *  Test this candidate to see if it passes the filter criteria
 *
 *  @param candidate - a WC Candidate measurement object
 *
 *  @return true if candidate passes this filter test
 */
- (BOOL) checkCandidate:(Candidate*) candidate;

/**
 *  Get the number of dropped candidate measurements.
 *
 *  @return number of dropped candidate measurements
 */
- (uint64_t) getCandidateDropCount;


- (uint64_t) getCandidateTotal;


@end
