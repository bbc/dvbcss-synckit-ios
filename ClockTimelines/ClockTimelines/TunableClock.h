

//  TunableClock.h
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 07/05/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "ClockBase.h"


/**
 * A clock whose tick offset and speed can be adjusted on the fly.
 * Must be based on another clock, a parent clock. A tunable clock specifies a correlation relationship
 * with respect to its parent clock. This correlation specifies a tick value, a tick rate and a speed value for this clock and a tick value from the parent clock as from which this relationship applies.
 *
 * Advancement of time of this clock is based on the tick count and rates reported by
 * the supplied parent clock.
 * If you adjust the tickRate or speed, then the change is applied going forward from the moment it is made.
 * E.g. if you are observing the rate of increase of the ticks property, then doubling the speed wil cause
 * the ticks property to start increasing faster but will not cause it to suddenly jump value.
 */
@interface TunableClock : ClockBase


/** Last tick value of parent clock from which tickRate and speed applies */
@property (nonatomic, assign) int64_t lastTicks;

/** Start tick count for this clock*/
@property (nonatomic, assign) int64_t startTicks;


/** This clock's slew*/
@property (nonatomic, assign, readwrite, getter=slew) int64_t slew;



/**
 *  Default-value init method disallowed. Use initWithParentClock() method instead.
 *
 */
- (instancetype)init MSDesignatedInitializer(initWithParentClock:);

/**
 *  Initialise a tunable clock instance.
 *
 *  @param parentClock parent clock used for advancement of time in this current clock
 *  @param tickRate    A frequency/tick rate in ticks per second for thic clock
 *  @param ticks       The starting tick count for this clock
 *
 *  @return a tunable clock instance
 */
- (instancetype) initWithParentClock:(ClockBase*) parentClock
                            TickRate:(uint64_t) tickRate
                               Ticks:(int64_t) ticks;



/**
 *  Rebase correlation of this tunable clock (with the parent clock) to the parent's clock current tick value.
 */
- (void) rebase;


/**
 *  Change the tick value of this clock by a specified offset value
 *
 *  @param offset offset tick value
 */
-(void) adjustTicks:(int64_t) offset;

/**
 *  Change the time value of this clock by a specified offset value
 *
 *  @param offset_nanos offset in nanoseconds
 */
-(void) adjustTimeNanos:(int64_t) offset_nanos;


/**
 *  Change the time value of this clock by a specified offset value and update the error value of this clock as well
 *  as the rate at which this error grows.
 *
 *  @param offset_nanos offset in nanoseconds
 *  @param staticErrorNanos a static error value in nanoseconds for this clock.
 *  @param errorRatePPM     the rate at which this clock's error grows
 */
-(void) adjustTimeNanos:(int64_t) offset_nanos
        WithStaticError:(int64_t) staticErrorNanos
           AndErrorRate:(int32_t) errorRatePPM;


@end
