//
//  TimelineOption.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 07/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "TimelineOption.h"

@implementation TimelineOption

@synthesize timelineSelector = _timelineSelector;
@synthesize timelineProperties = _timelineProperties;

+(instancetype) TimelineOptionWithSelector:(NSString*) timeline_select
                              UnitsPerTick:(int) unit_ticks
                            UnitsPerSecond:(int) units_sec
                                  Accuracy:(int) accuracy
{
    return [[TimelineOption alloc] initWithSelector:timeline_select
                                       UnitsPerTick:unit_ticks
                                     UnitsPerSecond:units_sec
                                           Accuracy:accuracy];
}

- (id) init: (NSString*) timeline_select Options:(TimelineProperties*) timeline_props{
    
    if ((self = [super init])) {
        
        _timelineSelector = timeline_select;
        _timelineProperties = timeline_props;
        
    }
    return self;
}



- (id) initWithSelector: (NSString*) timeline_select
           UnitsPerTick:(int) unit_ticks
         UnitsPerSecond:(int) units_sec
               Accuracy:(int) accuracy;{
    
    if ((self = [super init])) {
        
        _timelineSelector = timeline_select;
        
        _timelineProperties = [[TimelineProperties alloc] init];
        _timelineProperties.unitsPerTick = [NSNumber numberWithInt:unit_ticks];
        _timelineProperties.unitsPerSecond = [NSNumber numberWithInt:units_sec];
        _timelineProperties.accuracy = [NSNumber numberWithInt:accuracy];
        
    }
    return self;
}



- (BOOL) isEqual:(id)object
{
    if ([object class] == [TimelineOption class])
    {
        TimelineOption *timelineOpt =  (TimelineOption*) object;
        
        
        if ([timelineOpt.timelineSelector caseInsensitiveCompare:_timelineSelector] == NSOrderedSame) {
            return YES;
        }
        
        return NO;
        
    }else
        return NO;
}

@end
