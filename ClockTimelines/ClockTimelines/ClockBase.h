//
//  ClockBase.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 05/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "ClockProtocol.h"

#define MSDesignatedInitializer(__SEL__) __attribute__((unavailable("Invoke the designated initializer `" # __SEL__ "` instead.")))

#define _kOneThousandMillion  1000000000


FOUNDATION_EXPORT NSString * const ClockErrorDomain;

enum ClockError{
    NoCommonAncestorClockError=1
    
};

/**
 A base class for all clock objects. New clock classes must subclass the ClockBase class.
 */
@interface ClockBase : NSObject <ClockProtocol>

/**
 *  A parent clock for this clock.
 */
@property (strong, nonatomic) ClockBase *parent;

/**
 *  this clock's tickrate in number of ticks per second (required)
 */
@property (nonatomic, assign) uint64_t tickRate;


/**
 * this clock's speed. Specifies how time is mapped to child time space from the parent
 * time space. (required) For example, if speed is 2.0 local time progresses twice as fast
 * as parent time. Defaults to 1.0.
 */
@property (nonatomic, assign) float speed;

/**
 *  Sets or provides the availability of this clock.
 */
@property (nonatomic, assign) BOOL available;

/** 
 A clock error's static error component in nano seconds. In the simplest of cases, e.g. for a system clock
 this is the system clock's precision. In other clocks, this will include other non-time-varying sources of error
 e.g. for WallClock, the RTT
*/
@property (nonatomic, readwrite) int64_t staticError;


/** this clock's time-varying error. This is the rate at which the error for this clock grows.
 Specified in ppm (parts per million). A clock's  errorRate is the sum of its errorRate
 and the errorRate of its parent clock. For a SystemClock, this is equal to the frequency error.
    */
@property (nonatomic, readwrite, getter=errorRate) uint32_t errorRate;


/**
   Time in ticks on clock's timeline from which staticError and errorRate applies. In clocks where there are offset readjustments, the error
    parameters (staticError and errorRate) are updated at the time of adjustment and only apply from that time onwards.
 
 */
@property (nonatomic, readwrite) int64_t errorTicksFrom;




/**
 *  Returns the 'effective speed' of this clock. This is equal to multiplying together the speed properties of this clock and all of the parents up to the root clock
 *
 *  @return Returns the 'effective speed' of this clock
 */
- (float) getEffectiveSpeed;



/**
 *  Compute time in seconds from the tick value and this clock's tick rate
 *
 *  @param ticks time in ticks
 *
 *  @return time in seconds
 */
- (Float64) computeTime:(int64_t) ticks;


/**
 *  Compute time in nanoseconds from the tick value and this clock's tick rate
 *
 *  @param ticks time in ticks
 *
 *  @return time in nano secs
 */
- (Float64) computeTimeNanos:(int64_t) ticks;

/**
 *  Method to convert from a tick value for this clock to the equivalent tick value (representing the same point in time) for the parent clock.
 *
 *Implementations should use the parent clock's `tickRate` and `speed` properties when performing the conversion
 *
 *  @param ticks a tick value for this clock
 *
 *  @return The specified tick value of this clock converted to the timescale of the parent clock
 */
- (int64_t) toParentTicks:(int64_t) ticks;


/**
 *  Method to convert from a tick value for this clock's parent to the equivalent tick value (representing the same point in time) for this clock.
 Implementations should use this clock's `tickRate` and `speed` properties when performing the conversion.
 *
 *  @param ticks a tick value for this clock
 *
 *  @return The specified tick value for the parent clock converted to the timescale of this clock.
 */
- (int64_t) fromParentTicks:(int64_t) ticks;

/**
 *  Converts a tick value for this clock into a tick value corresponding to the timescale of another clock.
 *
 *  @param otherClock A ClockBase object representing another clock.
 *  @param ticks      A time (tick value) for this clock
 *  @param error      A pointer to an NSError pointer parameter
 *
 *  @return The tick value of the `otherClock` that represents the same moment in time. Users should 
 *  check the value returned in `error`. Error codes are specified in ClockErrors.h.
 */
- (int64_t) toOtherClock:(ClockBase*) otherClock
                    Ticks:(int64_t) ticks
                WithError:(NSError**) error;

/**
 *  measure this clock's precision
 *
 *  @param sampleSize number of samples for calculation
 *
 *  @return measured precision
 */
- (double) estimatePrecision:(NSUInteger) sampleSize;

/**
 *  Get the error of the clock reading at specified time. A clock reading's error value
 *  has a static error component and another error component which grows over time.
 *
 *  @param time time value in nanoseconds
 *
 *  @return error of this clock at time 'timeInNanos'
 */
- (int64_t) dispersionAtTime:(int64_t) timeInNanos;



/**
 *  Add an observer for clock state changes. Uses IOS's Key-Value-Coding mechanism.
 *
 *  @param observer the observer object to be notified
 *  @param context  A context to differentiate between observed clock objects
 */
- (void) addObserver:(id) observer context: (void*) context;


/**
 *  Remove observer from this clock object
 *
 *  @param observer observer to unregister
 *  @param context context to differentiate between clock objects
 */
- (void) removeObserver:(id) observer Context: (void*) context;


@end

