//
//  CorrelatedClock.m
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

#import "CorrelatedClock.h"
#import "TunableClock.h"

//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------

NSString* const  kCorrelationKey    = @"correlation";
NSString* const  kTickRateKey       = @"tickRate";
NSString* const  kSpeedKey          = @"speed";
NSString* const  kAvailableKey      = @"available";
NSString* const  kStartTicksKey     = @"startTicks";



//------------------------------------------------------------------------------
#pragma mark - CorrelationFactory implementation
//------------------------------------------------------------------------------
@implementation CorrelationFactory


+ (Correlation) create:(int64_t) parentTickValue
           Correlation:(int64_t) corelTickValue
{
    Correlation temp = (Correlation){parentTickValue, corelTickValue};
    return temp;
}

@end


//------------------------------------------------------------------------------
#pragma mark - CorrelatedClock implementation
//------------------------------------------------------------------------------

@implementation CorrelatedClock


@synthesize errorRate   = _errorRate;
@synthesize staticError = _staticError;

static void *correlationCLKContext = &correlationCLKContext;

//------------------------------------------------------------------------------
#pragma mark - Lifecycle methods: Initialization, Dealloc, etc
//------------------------------------------------------------------------------

- (instancetype) initWithParentClock:(ClockBase*) parentClock
                            TickRate:(uint64_t) tickRate
                         Correlation:(Correlation*) correl;
{
    self = [super init];
    if (self != nil) {
        self.parent = parentClock;
        self.tickRate = tickRate;
        self.speed = 1.0;
        self.correlation = *correl;
        
        _staticError = 0;
        _errorRate = 0;
        
        self.available = NO;
        
        [parentClock addObserver:self context:correlationCLKContext];
        
    }
    return self;
}

//------------------------------------------------------------------------------

- (void)dealloc
{
    
   [self.parent removeObserver:self
                       Context:correlationCLKContext];

}

//------------------------------------------------------------------------------

- (NSString*) description
{
    return [NSString stringWithFormat:@"parent clock: %@ %lu, tickrate: %llu Correlation (parentTicksValue, ticksValue): (%lld , %lld)",NSStringFromClass([self.parent class]), (unsigned long)[self.parent hash], self.tickRate, self.correlation.parentTickValue, self.correlation.tickValue];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void) rebaseCorrelationAtTicks:(int64_t) newTicks
{
    int64_t parentticksval = [self toParentTicks:newTicks];
    self.correlation = (Correlation){parentticksval, newTicks};
   
}

//------------------------------------------------------------------------------
#pragma mark - Overriding ClockBase methods
//------------------------------------------------------------------------------

// Correlated Clock - calculate time from ticks
- (Float64) computeTime:(int64_t) ticks{
    
    int64_t parentticks;
    
      if (self.speed == 0.0)
        parentticks = self.correlation.parentTickValue;
    else{
        
        
        Float64 ticksElapsed =  (ticks - _correlation.tickValue) * 1.0;
//        NSLog(@"In Correlated Clock: correlation.tickValue: %lld ticksElapsed: %lf", _correlation.tickValue, ticksElapsed);
        
        
        parentticks = self.correlation.parentTickValue + (((ticksElapsed/self.tickRate) * self.parent.tickRate)/self.speed);
//        NSLog(@"In Correlated Clock: parentticks:%llu", parentticks);
    }
    return [self.parent computeTime:parentticks];
}

//------------------------------------------------------------------------------

- (Float64) computeTimeNanos:(int64_t) ticks{
    return ([self computeTime:ticks] * _kOneThousandMillion);
}

//------------------------------------------------------------------------------

- (int64_t) toParentTicks:(int64_t) ticks
{
    if (self.speed == 0.0)
        return self.correlation.parentTickValue;
    else{
        Float64 ticksElapsed = (Float64) ticks - (Float64) self.correlation.tickValue;
//        Float64 x = self.correlation.parentTickValue + ((ticksElapsed/self.tickRate) * self.parent.tickRate)/self.speed;
        
        return self.correlation.parentTickValue + ((ticksElapsed/self.tickRate) * self.parent.tickRate)/self.speed;
    }
}

//------------------------------------------------------------------------------

- (int64_t) fromParentTicks:(int64_t) parent_ticks
{
    Float64 ticksElapsed = (Float64) (parent_ticks - self.correlation.parentTickValue);
    return self.correlation.tickValue + (ticksElapsed * self.tickRate * self.speed)/ self.parent.tickRate;
}

//------------------------------------------------------------------------------

-(uint32_t)errorRate
{
    // error rate is in ppm (parts per million)
    return _errorRate + self.parent.errorRate;
}

//------------------------------------------------------------------------------

- (int64_t)dispersionAtTime:(int64_t)timeInNanos{
    
    // get dispersion of parent at this time
    int64_t parent_ticks = [self toParentTicks:[self nanoSecondsToTicks:timeInNanos]];
    int64_t parent_dispersion = [self.parent dispersionAtTime:[self.parent ticksToNanoSeconds:parent_ticks]];
    
    int64_t time_diff = timeInNanos - [self ticksToNanoSeconds: self.errorTicksFrom];
    
    return (parent_dispersion + self.staticError + ((self.parent.errorRate + _errorRate) * time_diff)/1000000);
    
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Implementing protocol ClockProtocol methods
//------------------------------------------------------------------------------


- (int64_t) ticks{
    return [self fromParentTicks: [self.parent ticks]] ;
}

//------------------------------------------------------------------------------

- (Float64) time
{
    return  (self.ticks*1.0)/self.tickRate;
}


//------------------------------------------------------------------------------
#pragma mark - Clock Key-Value observation methods
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
/// @name Overriding ClockBase's Clock Key-Value observation methods
//------------------------------------------------------------------------------

/**
 *  Add an observer for clock state changes. Uses IOS's Key-Value-Coding mechanism.
 *
 *  @param observer the observer object to be notified
 *  @param context  A context to differentiate between observed clock objects
 */
- (void) addObserver:(id) observer
             context: (void*) context
{
    [self addObserver:observer
           forKeyPath:kCorrelationKey
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    [self addObserver:observer
           forKeyPath:kTickRateKey
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    [self addObserver:observer
           forKeyPath:kSpeedKey
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    [self addObserver:observer forKeyPath:kAvailableKey
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    if ([self.parent isKindOfClass:[TunableClock class]]) {
        [self addObserver:observer
               forKeyPath:kStartTicksKey
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:context];
    }
}

//------------------------------------------------------------------------------

/**
 *  Remove observer from this clock object
 *
 *  @param observer observer to unregister
 *  @param context context to differentiate between clock objects
 */
- (void) removeObserver:(id) observer
                Context: (void*) context
{
    [self removeObserver:observer forKeyPath:kCorrelationKey context:context];
    [self removeObserver:observer forKeyPath:kTickRateKey context:context];
    [self removeObserver:observer forKeyPath:kSpeedKey context:context];
    [self removeObserver:observer forKeyPath:kAvailableKey context:context];
    if ([self.parent isKindOfClass:[TunableClock class]])
        [self removeObserver:observer forKeyPath:kStartTicksKey context:context];

}

//------------------------------------------------------------------------------

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"%@", change);
    
//    BOOL parentChanged = ([keyPath isEqualToString:kTickRateKey] ||
//                            [keyPath isEqualToString:kSpeedKey] ||
//                            [keyPath isEqualToString:kCorrelationKey] ||
//                          [keyPath isEqualToString:kStartTicksKey]);
    
    // trigger a KVO notification to dependents/observers through a fake change to a similar property
    
    if ([keyPath isEqualToString:kTickRateKey]) {
        
        uint64_t temp = self.tickRate;
        self.tickRate = temp;
    }
    
    if ([keyPath isEqualToString:kSpeedKey]) {
        
        float oldSpeed = [[change objectForKey:@"old"]floatValue];
        float newSpeed = [[change objectForKey:@"new"]floatValue];
        
        self.speed = newSpeed;
        
        //NSLog(@"CorrelatedClock: parent's speed changed from %f to %f", oldSpeed, newSpeed);
    }
    
    if ([keyPath isEqualToString:kCorrelationKey]) {
        Correlation temp = self.correlation; // deep copy
        self.correlation = temp;
    }
    
    if ([keyPath isEqualToString:kAvailableKey]) {
        
        
        BOOL old = [[change objectForKey:@"old"]boolValue];
        BOOL new = [[change objectForKey:@"new"]boolValue];
        
       
        self.available = new;
    
    
    }
    
    
//    if ([keyPath isEqualToString:kStartTicksKey]) {
//        Correlation temp = self.s; // deep copy
//        self.correlation = temp;
//    }
    
}


//------------------------------------------------------------------------------


@end
