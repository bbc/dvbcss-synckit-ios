//
//  TimelineOption.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 07/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimelineProperties.h"

/**
 *  Class to represent a Timeline description
 */
@interface TimelineOption : NSObject

/**
 *  Timeline selector string
 */
@property (nonatomic, readwrite) NSString*  timelineSelector;

/**
 *  Timeline propertries
 */
@property (nonatomic, readwrite) TimelineProperties* timelineProperties;

/**
 *  Creates a TimelineOption instance
 *
 *  @param timeline_select Timeline selector string
 *  @param unit_ticks      units per tick
 *  @param units_sec       units per second
 *  @param accuracy        timeline's precision i.e. its granularity
 *
 *  @return a TimelineOption instance
 */
+(instancetype) TimelineOptionWithSelector:(NSString*) timeline_select
                              UnitsPerTick:(int) unit_ticks
                            UnitsPerSecond:(int) units_sec
                                  Accuracy:(int) accuracy;

/**
 *  Initialiser
 *
 *  @param timeline_select Timeline selector string
 *  @param unit_ticks      units per tick
 *  @param units_sec       units per second
 *  @param accuracy        timeline's precision i.e. its granularity *
 *  @return initialised instance
 */
- (id) init: (NSString*) timeline_select Options:(TimelineProperties*) timeline_props;

/**
 *  Initialiser
 *
 *  @param timeline_select Timeline selector string
 *  @param timeline_props  Timeline properties
 *
 *  @return initialised instance
 */

- (id) initWithSelector: (NSString*) timeline_select
           UnitsPerTick:(int) unit_ticks
         UnitsPerSecond:(int) units_sec
               Accuracy:(int) accuracy;

- (BOOL) isEqual:(id)object;

@end
