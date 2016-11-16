//
//  ConfigurableClock.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 06/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//


#import "ClockBase.h"


/** A configurable clock class whose tick offset and frequency can be set dynamically
 It is driven by a master clock (or reference clock), for example, the SystemClock
 (a type of ClockBase)
*/
@interface ConfigurableClock : ClockBase

/**
 * initialises instance of ConfigurableClock with a master clock, rate relative to the master clock and initial tick count
 *
 * @param aClock an instance of or an object which is a subtype of ClockBase, which will be the master clock driving this clock
 * @param rate a relative rate with respect to the frequency (ticks per second) of the master clock. A rate of 0.0 means the 
 * ConfigurableClock does not advance over time. A rate of 1.0 means that the ConfigurableClock progresses forward at the same frequency
 * as its master clock; a rate of -0.5 means that ConfigurableClock time progresses backwards at the half the rate of the master clock.
 * @param ticks initial tick count
 * @return an instance of the configurable clock.
 */
- (id) initWithClock: (ClockBase*) aClock Rate:(float) rate Ticks:(uint64_t) ticks;


- (id) initWithClock: (ClockBase*) aClock Rate:(float) rate NanosOffset:(uint64_t) offsetns;


/**
 Start the clock from ticks offset at specified rate and offset
 */
- (void) start;

/**
  Stop the clock; set active to false
 */
- (void) invalidate;

/**
 adjust the clock tick count
 */
- (void) adjustTicks:(uint64_t) offset;

/**
 adjust the clock's time
 */
- (void) adjustNanos:(uint64_t) offset_nanos;

- (void) adjustNegNanos:(int64_t) offset_nanos;

/**
 * adjust the clock's rate relative to the master clock
 */
- (void) adjustRate:(float) rate;

/** Convert a timestamp on this clock to a corresponding timestamp on the master clock
 @param timeInNanos timestamp in nano seconds
 */
- (uint64_t) NanosToMasterClockNanos:(uint64_t) timeInNanos;

/** Master clock to drive this clock */
@property (atomic, readonly) ClockBase* masterClock;
/** A multiplier to the tick rate of the master clock. */
@property (atomic, readonly) float rate;
/** Start tick count for this clock*/
@property (atomic, readonly) uint64_t ticks;
/** Boolean flag for clock activity */
@property (atomic, readonly, getter = isActive) BOOL active;


@end
