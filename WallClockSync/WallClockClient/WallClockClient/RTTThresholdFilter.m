//
//  RTTThresholdFilter.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "RTTThresholdFilter.h"


@interface RTTThresholdFilter()
{
    
}

@end


@implementation RTTThresholdFilter
{
    uint64_t drop_count;
    uint64_t count;
}

@synthesize RTTThresholdNanos =  _RTTThresholdNanos;

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        drop_count = 0;
        _RTTThresholdNanos = 200000000; // 200 ms
    }
    return self;
}


- (id)initWithThreshold:(uint32_t) rtt_threshold_ms
{
    self = [super init];
    if (self != nil) {
        
        drop_count = 0;
        _RTTThresholdNanos = rtt_threshold_ms * 1000000; // in nano secs
    }
    return self;
}


- (BOOL) checkCandidate:(Candidate *)candidate
{
    if (!candidate) return false;
    
    // rollover counter if it is greater than 1 billion
    count = count == 1e9?1:count++;
    
    if ([candidate getRTT] > _RTTThresholdNanos) {
        drop_count = (drop_count+1) &1000000000;
        //NSLog(@"REJECTED! Candidate RTT %lld > %lld",[candidate getRTT] , _RTTThresholdNanos);
        
        return false;
    }else
        return true;
}


- (uint64_t)getCandidateDropCount{
    
    return drop_count;
}

-(uint64_t)getCandidateTotal
{
    return count;
}

@end
