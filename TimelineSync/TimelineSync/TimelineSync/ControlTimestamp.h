//
//  ControlTimestamp.h
//
//  Created by Rajiv Ramdhany  on 09/10/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ClockTimelines/CorrelatedClock.h>

//------------------------------------------------------------------------------
#pragma mark - keys
//------------------------------------------------------------------------------

/**
 *  ContentTime field name in Control Timestamp message
 */
FOUNDATION_EXPORT NSString * const kCrtlTimestampContentTime;

/**
 *  WallClockTime field name in Control Timestamp message
 */
FOUNDATION_EXPORT NSString * const kCrtlTimestampWallClockTime;

/**
 *  TimelineSpeedMultiplier field name in Control Timestamp message
 */
FOUNDATION_EXPORT NSString * const kCrtlTimestampTimelineSpeedMultiplier;


//------------------------------------------------------------------------------
#pragma mark - ControlTimestamp
//------------------------------------------------------------------------------

/**
 *  Class representing Control Timestamps reported by the DVB-CSS Timeline Synchronisation protocol.
 *  It provides operations to serialise and de-serialise control timestamps.
 */
@interface ControlTimestamp : NSObject <NSCoding, NSCopying>


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  String representation of Content Time (position on TV's timeline, time in nanoseconds)
 */
@property (nonatomic, strong) NSString *contentTime;

//------------------------------------------------------------------------------

/**
 *  String representation of WallClock Time (position on WallClock Timeline, time in timeline ticks e.g. PTS ticks for Presentation Timestamp timeline)
 */
@property (nonatomic, strong) NSString *wallClockTime;

//------------------------------------------------------------------------------

/**
 *  Time speed multiplier of TV's timeline
 */
@property (nonatomic, assign) double timelineSpeedMultiplier;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------

/**
 *  Create a ControlTimestamp instance from a dictionary containing known fields and values
 *
 *  @param dict a dictionary containing values for keys kCrtlTimestampContentTime, kCrtlTimestampWallClockTime, kCrtlTimestampTimelineSpeedMultiplier
 *
 *  @return a ControlTimestamp instance
 */
+ (instancetype)ControlTimestampWithDictionary:(NSDictionary *)dict;

//------------------------------------------------------------------------------
#pragma mark - Initialisation
//------------------------------------------------------------------------------

/**
 *  Initialise with a dictionary containing values for keys kCrtlTimestampContentTime, kCrtlTimestampWallClockTime, kCrtlTimestampTimelineSpeedMultiplier
 *
 *  @param dict a dictionary
 *
 *  @return a ControlTimestamp instance
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;


//------------------------------------------------------------------------------
#pragma mark - Encoding methods
//------------------------------------------------------------------------------

/**
 *  Serialise ControlTimestamp object to an NSDictionary
 *
 *  @return an NSDisctionary instance
 */
- (NSDictionary *) toDictionary;


//------------------------------------------------------------------------------

@end
