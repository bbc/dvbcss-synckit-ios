//
//  SystemClock.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 15/04/2015.
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

#import "SystemClock.h"


@interface SystemClock()

@end


@implementation SystemClock
{
    MonotonicTime *monTime;
    CMClockRef clockref;
}

@synthesize errorRate   = _errorRate;
@synthesize errorTicksFrom = _errorTicksFrom;

#pragma mark initialisation and description routines
///-----------------------------------------------------------
/// @name initialisation and description methods
///-----------------------------------------------------------
- (id) initWithTickRate:(uint64_t) tickrate
{
    self = [super init];
    if (self != nil) {
        self.speed = 1.0;
        monTime = [[MonotonicTime alloc] init];
        clockref = CMClockGetHostTimeClock();
        assert(clockref != nil);
        self.tickRate = tickrate;
        self.staticError = ([self estimatePrecision:10] * _kOneThousandMillion);
       _errorRate = 0;
        _errorTicksFrom = 0;
        
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SystemClock description:\nTick rate: %llu Speed: %f",self.tickRate, self.speed];
}



#pragma mark ClockProtocol methods
///-----------------------------------------------------------
/// @name ClockProtocol methods
///-----------------------------------------------------------
- (int64_t) ticks{
        return [monTime time] * self.tickRate;
}

- (uint64_t) ticksPerSecond
{
    return self.tickRate;
}

- (Float64) time
{
    return (((Float64)[self ticks]) / [self ticksPerSecond]);
}

- (int64_t) nanoSeconds{
    
    Float64 result = ((Float64)[self ticks] / [self ticksPerSecond]);
    
    int64_t nanos =result * _kOneThousandMillion;
    
    //NSLog(@"Clock ticks = %lld ticksPerSecond=%llu, nanos = %lld ", [self getTicks], [self getTicksPerSecond], nanos);
    
    return nanos;
}


#pragma mark ClockBase methods

///-----------------------------------------------------------
/// @name ClockBase methods
///-----------------------------------------------------------

// System Clock - calculate time from ticks
- (Float64) computeTime:(int64_t) ticks{
    
    return (Float64)ticks/self.tickRate;
}


- (Float64) computeTimeNanos:(int64_t) ticks{
    
    return ((Float64)ticks/self.tickRate) * _kOneThousandMillion;
}


- (int64_t) toParentTicks:(int64_t) ticks
{
    NSException *e = [NSException
                      exceptionWithName:@"StopIteration"
                      reason:@"clock is root"
                      userInfo:nil];
    @throw e;
}

- (int64_t) fromParentTicks:(int64_t) ticks
{
    NSException *e = [NSException
                      exceptionWithName:@"StopIteration"
                      reason:@"clock is root"
                      userInfo:nil];
    @throw e;

}


- (uint32_t) errorRate
{
    // clock  is root, return only the errorRate of this clock
    
    return _errorRate;
}



- (int64_t)dispersionAtTime:(int64_t)timeInNanos
{
    // for the system clock, the errorRate is zero.
    return self.staticError + self.errorRate * (timeInNanos - self.errorTicksFrom)/1000000;
}


#pragma host time methods
///-----------------------------------------------------------
/// @name host time methods
///-----------------------------------------------------------
- (CMTime) hostTime
{
    
   return CMClockGetTime(clockref);
}



@end
