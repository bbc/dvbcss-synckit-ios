//
//  RTTThresholdFilter.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFilter.h"

/**
 *  Simple filter that rejects all candidates where round trip time exceeds a specified threshold.
 */
@interface RTTThresholdFilter : NSObject <IFilter>

/**
 *  RTT threshold in nano seconds
 */
@property (nonatomic, readwrite) uint64_t RTTThresholdNanos;


- (instancetype)init NS_UNAVAILABLE;

/**
 *  initialise filter with an RTT threshold value in milliseconds.
 *
 *  @param rtt_threshold_ms rtt threshold value in milliseconds
 *
 *  @return initialised RTTThresholdFilter instance
 */
- (id)initWithThreshold:(uint32_t) rtt_threshold_ms;

@end
