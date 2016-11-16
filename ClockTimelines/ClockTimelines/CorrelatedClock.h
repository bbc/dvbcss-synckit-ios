//
//  CorrelatedClock.h
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 27/04/2015.
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


//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------
/**
 *  Struct representing a correlation tuple (parenttickvalue, correlatedclocktockvalue)
 */
typedef struct _correlation{
    
    // parent clock tick value
    int64_t    parentTickValue;
    
    // this correlated clock's tick value
    int64_t    tickValue;
    
}Correlation;

//------------------------------------------------------------------------------
#pragma mark - Constants, Keys Declarations
//------------------------------------------------------------------------------

/**
 *  correlation key
 */
FOUNDATION_EXPORT NSString* const  kCorrelationKey;

/**
 *  tickrate key
 */
FOUNDATION_EXPORT NSString* const  kTickRateKey;

/**
 *  speed key
 */
FOUNDATION_EXPORT NSString* const  kSpeedKey;

/**
 *  speed key
 */
FOUNDATION_EXPORT NSString* const  kAvailableKey;

/**
 *  speed key
 */
FOUNDATION_EXPORT NSString* const  kStartTicksKey;


//------------------------------------------------------------------------------
#pragma mark - Local Class CorrelationFactory Definition
//------------------------------------------------------------------------------
@interface CorrelationFactory : NSObject

/**
 *  Factory method for Correlation instance
 *
 *  @param parentTickValue a tick value for the parent clock
 *  @param corelTickValue  a tick value for the correlated clock
 *
 *  @return a Correlation
 */
+ (Correlation) create:(int64_t) parentTickValue
           Correlation:(int64_t) corelTickValue;

@end
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - CorrelatedClock Class Definition
//------------------------------------------------------------------------------
/**
    `CorrelatedClock` is a clock locked to the tick count of the parent clock by a correlation and frequency setting. Correlation is a tuple (parentTicks, selfTicks). When the parent clock ticks property has the value `parentTicks`, the ticks property of this clock shall have the value `selfTicks`.
 
     @discussion You can alter the correlation and tickRate and speed of this clock dynamically. Changes to tickRate and speed
    will not shift the point of correlation. This means that a change in tickRate or speed will probably cause the
    current tick value of the clock to jump. The amount it jumps by will be proportional to the distance the current
    time is from the point of correlation.
 
    If you want a speed change to only affect the ticks from a particular point (e.g. the current tick value) onwards
    then you must re-base the correlation. 
    
    @warning The maths to calculate and convert tick values will be performed, by default, as integer maths
    unless the parameters controlling the clock (tickRate etc) are floating point, or the ticks property
    of the parent clock supplies floating point values.
 
    There is a function provided to do that in some circumstances:
 
    @code  c = CorrelatedClock(parentClock=parent, tickRate=1000, correlation=(50,78))
 
            ... time passes ...
 
            // now freeze the clock AT ITS CURRENT TICK VALUE
 
            c.rebaseCorrelationAtTicks(c.ticks)
            c.speed = 0
 
            // now resume the clock but at half speed, but again without the tick value jumping
            c.correlation = ( parent.ticks, c.ticks )
            c.speed = 0.5;
 */
@interface CorrelatedClock : ClockBase

//------------------------------------------------------------------------------
#pragma mark - properties
//------------------------------------------------------------------------------

/**
 *  The underlying correlation for the timeline represented by this clock with respect to its parent timeline (clock)
 */
@property (nonatomic, readwrite) Correlation correlation;



//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------


/**
 *  Default-value init method disallowed. Use initWithTickRate() method instead.
 *
 */
- (instancetype)init MSDesignatedInitializer(initWithParentClock:TickRate:Correlation:);

//------------------------------------------------------------------------------

/**
 *  initialise a CorrelatedClock instance
 *
 *  @param parentClock this clock's immediate parent
 *  @param tickRate    tickrate/frequency for this clock
 *  @param correl      correlation tuple (parent_tick_value)
 *
 *  @return CorrelatedClock instance
 */
- (instancetype) initWithParentClock:(ClockBase*) parentClock
                            TickRate:(uint64_t) tickRate
                         Correlation:(Correlation*) correl;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Returns a string representation of this object
 *
 *  @return string representation of this object
 */
- (NSString*) description;

//------------------------------------------------------------------------------

/**
 *  Changes the `correlation` property to an equivalent correlation (that does not change the timing relationship between parent clock and this clock) where the tick value for this clock is the provided tick value.
 *  @discussion If you want a change (e.g. speed change) to only affect the ticks from a particular point (e.g. the current tick value) onwards then you must re-base the correlation.
 *
 *  @param newTicks tickvalue of this clock from which the new correlation applies
 *  @code CorrelatedClock *c = [CorrelatedClock alloc] initWithParentClock:parent 
                                                                  TickRate: tickRate, 
                                                                correlation=(50,78))
 
 ... time passes ...
 
 # now freeze the clock AT ITS CURRENT TICK VALUE
 
 c.rebaseCorrelationAtTicks(c.ticks)
 c.speed = 0
 
 # now resume the clock but at half speed, but again without the tick value jumping
 c.correlation = ( parent.ticks, c.ticks )
 c.speed = 0.5
 */
- (void) rebaseCorrelationAtTicks:(int64_t) newTicks;

//------------------------------------------------------------------------------



@end
