//
//  MonotonicTime.h
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

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>
#import <AVFoundation/AVFoundation.h>

/**
 *  A class to calculate monotinic time from the host's system clock
 */
@interface MonotonicTime : NSObject

/**
 *  Frequency of the system clock in ticks per second
 */
@property (nonatomic, readonly) Float64 frequency;

/**
 
 A read-only property containing the reference to the system clock
 */
@property (nonatomic, readonly) CMClockRef clockref;




/**
 *  Return current host time in seconds
 *
 *  @return current host time in seconds (floating point number)
 */
- (Float64) time;

/**
 *  Return current hosttime in milliseconds
 *
 *  @return current host time in milliseconds
 */
- (Float64) timeMillis;

/**
 *  Return current host time in microseconds
 *
 *  @return current host time in microseconds
 */
- (Float64) timeMicros;

/**
 *  Return current host time in nanoseconds
 *
 *  @return current host time in nanos
 */
- (UInt64) timeNanos;

/**
 *  Return this host's absolute time
 *
 *  @return host's absolute time
 */
- (UInt64) absoluteTimeUnits;


/**
 *  Return host clock's frequency
 *
 */
- (Float64) hostFrequency;




@end
