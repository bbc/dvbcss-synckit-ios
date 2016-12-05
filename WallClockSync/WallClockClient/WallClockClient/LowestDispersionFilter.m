//
//  LowestDispersionFilter.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "LowestDispersionFilter.h"
#import <ClockTimelines/ClockTimelines.h>




// TODO:
// 1. rollover drop_count counter
// 2. max dispersion
// 3. moving average for dispersion

@interface LowestDispersionFilter()
{
    
}

@end


@implementation LowestDispersionFilter
{
    uint64_t         drop_count;
    uint64_t         count;
}

@synthesize bestCandidate = _bestCandidate;


- (id)initWithWallClock:(ClockBase*) clock_ AndBestCandidate:(Candidate*) candidate
{
    self = [super init];
    if (self != nil) {
        count           = 0;
        drop_count      = 0;
        _bestCandidate  = candidate;
        _wallclockRef   = clock_;
    }
    return self;
}


- (void)dealloc
{
    _bestCandidate = nil;
    _wallclockRef = nil;
}

- (BOOL) checkCandidate:(Candidate *)candidate
{
    if (candidate == nil) return false;
    
    // rollover counter if it is greater than 1 billion
    count = count == 1e9?1:count++;
    
    int64_t dispersion = [candidate getDispersionAtTime:[self.wallclockRef nanoSeconds]];

    if (_bestCandidate == nil)
    {
        _bestCandidate = candidate;
        return true;
    }else
    {
       int64_t best_dispersion = [candidate getDispersionAtTime:[self.wallclockRef nanoSeconds]];
        
        if (dispersion < best_dispersion){
            _bestCandidate = candidate;
            return true;
        }else{
            drop_count = (drop_count == 1e9)?1:drop_count++;
            return false;
        }
    }
}


- (uint64_t)getCandidateDropCount
{
    return drop_count;
}


-(uint64_t)getCandidateTotal
{
    return  count;
    
}


@end
