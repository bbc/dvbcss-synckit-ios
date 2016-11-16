//
//  TunableClock.m
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

#import "TunableClock.h"

@interface TunableClock()



@end


@implementation TunableClock


@synthesize tickRate    = _tickRate;
@synthesize speed       = _speed;
@synthesize lastTicks   = _lastTicks;
@synthesize slew        = _slew;
@synthesize errorRate   = _errorRate;
@synthesize staticError = _staticError;


#pragma mark initialisation and description routines
///-----------------------------------------------------------
/// @name initialisation and description methods
///-----------------------------------------------------------
- (instancetype) initWithParentClock:(ClockBase*) parentClock
                            TickRate:(uint64_t) tickRate
                               Ticks:(int64_t) ticks
{
    self = [super init];
    if (self != nil) {
        self.parent = parentClock;
        _tickRate = tickRate;
        _startTicks = ticks;
        _speed = 1.0;
        self.lastTicks = [parentClock ticks];
        self.staticError = [self estimatePrecision:10] * _kOneThousandMillion;
        self.errorRate = 0;
        self.errorTicksFrom = 0;
        self.available = NO;
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"TunableClock description:\n%@ lastTicks: %lld\nstartTicks: %lld\n",[super description], self.lastTicks, self.startTicks];
}

#pragma mark ClockBase methods
///-----------------------------------------------------------
/// @name overriding ClockBase setters and getters
///-----------------------------------------------------------

-(void) setTickRate:(uint64_t)tickRate
{
    [self rebase];
    _tickRate =  tickRate;
    // observers of change are notified via KVO. (See ClockBase class for observer registration methods)
}


- (void) setSpeed:(float)speed
{
    [self rebase];
    _speed = speed;
    // observers of change are notified via KVO. (See ClockBase class for observer registration methods)
}


-(void) setSlew:(int64_t)slew
{
    _speed = ((float) slew / self.tickRate) + 1.0;
    _slew = slew;
}


- (int64_t) slew
{
    return (self.speed - 1.0)*self.tickRate;
}


- (int64_t) ticks
{
    
    int64_t now = [self.parent ticks];
    //NSLog(@"Calculating tunable Clock ticks: system Clock ticks: %llu" , now);
    
    int64_t ticksElapsed = now - _lastTicks;
    //NSLog(@"Calculating tunable Clock ticks: ticks elapsed: %llu" , ticksElapsed);
    
    uint64_t ticksElapsedTuneCLK = ((ticksElapsed * self.speed* self.tickRate)/self.parent.tickRate);
   //NSLog(@"Calculating tunable Clock ticks: ticksElapsedTuneCLK: %llu" , ticksElapsedTuneCLK);
    
    int64_t temp =  _startTicks + ticksElapsedTuneCLK;
    //NSLog(@"Calculating tunable Clock ticks: ticks: %llu" , temp);
    
    return temp;
}


#pragma mark TunableClock class methods
///-----------------------------------------------------------
/// @name  TunableClock methods
///-----------------------------------------------------------
- (void) rebase
{
    uint64_t now = [self.parent ticks];
    uint64_t ticksElapsed = now - _lastTicks;
    
    _startTicks += (ticksElapsed * self.tickRate * self.speed)/self.parent.tickRate;
    _lastTicks = now;
}



-(void) adjustTicks:(int64_t) offset
{
    _startTicks +=  offset;
       
    //NSLog(@"TunableClock: StartTicks updated to: %lld", _startTicks);
    self.errorTicksFrom = [self ticks];
    
    // observers of change are notified via KVO. (See ClockBase class for observer registration methods)
}


-(void) adjustTimeNanos:(int64_t) offset_nanos
{
    
    int64_t offset_ticks = [self nanoSecondsToTicks:offset_nanos];
    
    [self adjustTicks:offset_ticks];
    
    
}


-(void) adjustTimeNanos:(int64_t)offset_nanos
        WithStaticError:(int64_t)staticErrorNanos
           AndErrorRate:(int32_t)errorRatePPM
{
    int64_t offset_ticks = [self nanoSecondsToTicks:offset_nanos];
    
    [self adjustTicks:offset_ticks];
    
    _staticError = staticErrorNanos;
    
    _errorRate = errorRatePPM;
    
}


- (Float64) time
{
    return  (self.ticks*1.0)/self.tickRate;
}


#pragma mark ClockBase abstract methods implementation
///-----------------------------------------------------------
/// @name overriding ClockBase methods
///-----------------------------------------------------------

// Tunable Clock
- (Float64) computeTime:(int64_t) __ticks__{
    
    int64_t parentticks;
    
    if (self.speed == 0.0)
        parentticks = _lastTicks;
    else{
        Float64 ticksElapsed = (__ticks__ - _startTicks) * 1.0;

        // some debug statements
//        Float64 test = (ticksElapsed/self.tickRate);
//         Float64 test2 = (ticksElapsed/self.tickRate)* self.parent.tickRate;
//        
//        Float64 result = _lastTicks + test2;
        
        parentticks = _lastTicks + ((ticksElapsed/self.tickRate) * self.parent.tickRate)/self.speed;
        
    }
    
    return [self.parent computeTime:parentticks];
}

- (Float64) computeTimeNanos:(int64_t) ticks{
    
    return ([self computeTime:ticks] * _kOneThousandMillion);
}


- (int64_t) toParentTicks:(int64_t) ticks_
{
    if (self.speed == 0.0)
        return _lastTicks;
    else{
        Float64 ticksElapsed = ticks_ - _startTicks;
        return _lastTicks + ((ticksElapsed/self.tickRate) * self.parent.tickRate)/self.speed;
    }
    
}

- (int64_t) fromParentTicks:(int64_t) ticks
{
    if (self.speed == 0.0)
        return self.ticks;
    else{
        Float64 parentTicksElapsed = ticks - _lastTicks;
        
        return _startTicks + ((parentTicksElapsed/self.parent.tickRate) * self.tickRate *self.speed);
    }
}



-(uint32_t)errorRate
{
    // error rate is in ppm (parts per million)
    return _errorRate + self.parent.errorRate;
}


- (int64_t)dispersionAtTime:(int64_t)timeInNanos{
    
    // get dispersion of parent at this time
    int64_t parent_ticks = [self toParentTicks:[self nanoSecondsToTicks:timeInNanos]];
    int64_t parent_dispersion = [self.parent dispersionAtTime:[self.parent ticksToNanoSeconds:parent_ticks]];
    
    int64_t time_diff = timeInNanos - [self ticksToNanoSeconds: self.errorTicksFrom];
    
    return (parent_dispersion + self.staticError + ((self.parent.errorRate + _errorRate) * time_diff)/1000000);
    
}


#pragma mark Clock Key-Value observation methods
///-----------------------------------------------------------
/// @name Clock Key-Value observation methods from base class ClockBase
///-----------------------------------------------------------
/**
 *  Override observer registration  method from base class ClockBase
 *
 *  @param observer the observer object to be notified
 *  @param context  A context to differentiate between observers
 */
- (void) addObserver:(id) observer
             context: (void*) context
{
    [self addObserver:observer
           forKeyPath:@"tickRate"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    [self addObserver:observer
           forKeyPath:@"speed"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    [self addObserver:observer
           forKeyPath:@"ticks"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    [self addObserver:observer
           forKeyPath:@"startTicks"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
}

/**
 *  Remove observer from this clock object
 *
 *  @param observer observer to unregister
 *  @param context context to differentiate between clock objects
 */
- (void) removeObserver:(id) observer
                Context: (void*) context
{
    [self removeObserver:observer forKeyPath:@"tickRate" context:context];
    [self removeObserver:observer forKeyPath:@"speed" context:context];
    [self removeObserver:observer forKeyPath:@"ticks" context:context];
}



@end
