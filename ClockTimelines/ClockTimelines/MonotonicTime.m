//
//  MonotonicTime.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 31/03/2015.
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

#import "MonotonicTime.h"


@interface MonotonicTime()

// redefine as readwrite
@property (nonatomic, readwrite) Float64 frequency;
@property (nonatomic, readwrite) UInt32 sToNanosDenominator;
@property (nonatomic, readwrite) UInt32 sToNanosNumerator;
@property (nonatomic, readwrite) CMClockRef clockref;

@end


@implementation MonotonicTime
{
    // dividers
    Float64 dividerSecs;
    Float64 dividerMillis;
    Float64 dividerMicros;
    Float64 dividerNanos;
}

static mach_timebase_info_data_t s_timebase_info;


#pragma mark Initialisation

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        
        _clockref = CMClockGetHostTimeClock();
        assert(_clockref != nil);
        
        
        if (s_timebase_info.denom == 0) {
            (void) mach_timebase_info(&s_timebase_info);
        }
        
        assert(s_timebase_info.denom != 0);
        
        self.sToNanosDenominator = s_timebase_info.denom;
        self.sToNanosNumerator = s_timebase_info.numer;
        
        self.frequency = (Float64)(self.sToNanosDenominator) / (Float64)(self.sToNanosNumerator);
        self.frequency *= 1.0e9;
        
        dividerSecs     =  1.0e9 * self.sToNanosDenominator/self.sToNanosNumerator;
        dividerMillis   =  1.0e6 * self.sToNanosDenominator/self.sToNanosNumerator;
        dividerMicros   =  1000.0 * self.sToNanosDenominator/self.sToNanosNumerator;
        dividerNanos    =  self.sToNanosDenominator/self.sToNanosNumerator;
        
    }
    
    return self;
}

#pragma mark interface methods
/**
 *  Return current host time in seconds
 *
 *  @return current host time in seconds (floating point number)
 */
- (Float64) time
{
    return mach_absolute_time() / dividerSecs;
}

/**
 *  Return current hosttime in milliseconds
 *
 *  @return current host time in milliseconds
 */
- (Float64) timeMillis
{
    return mach_absolute_time() / dividerMillis;
}

/**
 *  Return current host time in microseconds
 *
 *  @return current host time in microseconds
 */
- (Float64) timeMicros
{
    return mach_absolute_time() / dividerMicros;
}

/**
 *  Return current host time in nanoseconds
 *
 *  @return current host time in nanos
 */
- (UInt64) timeNanos
{
    return mach_absolute_time() / dividerNanos;
}


/**
 *  Return this host's absolute time
 *
 *  @return host's absolute time
 */
-(UInt64) absoluteTimeUnits
{
    return mach_absolute_time();
}


/**
 *  Return host clock's frequency
 *
 */
- (Float64) hostFrequency
{
    return self.frequency;
}



#pragma mark cleanup
- (void)dealloc
{
    
}
@end
