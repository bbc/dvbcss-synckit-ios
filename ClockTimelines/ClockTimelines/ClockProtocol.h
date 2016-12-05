//
//  ClockProtocol.h
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
#import <CoreMedia/CoreMedia.h>
#include <unistd.h>

/*
  A set of methods that are implemented by clock objects
 */
@protocol ClockProtocol <NSObject>



@optional

/**
 get tick count of clock
*/
- (int64_t) ticks;

/**
 return current tick rate or frequency
 */
- (uint64_t) ticksPerSecond;

/**
 Get the tick count of this clock, but converted to units of nanoseconds given the current tick rate of this clock
*/
- (int64_t) nanoSeconds;

/**
 Convert the supplied nanosecond to number of ticks given the current tick rate of this clock
 */
- (int64_t) nanoSecondsToTicks:(int64_t) nanos ;

/**
 Convert ticks to nano seconds given the tick rate of this clock
 */
- (int64_t) ticksToNanoSeconds:(int64_t)ticks;


/**
 get current time according to this clock
 */
- (Float64) time;



   
@end
