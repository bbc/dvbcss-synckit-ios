//
//  TimelineProperties.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 07/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "TimelineProperties.h"

@implementation TimelineProperties

@synthesize unitsPerTick = _unitsPerTick;
@synthesize unitsPerSecond = _unitsPerSecond;
@synthesize accuracy = _accuracy;


- (id) init: (NSNumber*) units_per_tick Properties: (NSNumber*) units_per_sec Accuracy:(NSNumber*) accuracy{
    
    if ((self = [super init])) {
        _unitsPerTick = units_per_tick;
        _unitsPerSecond = units_per_sec;
        _accuracy = accuracy;
    }
    return self;
}


@end
