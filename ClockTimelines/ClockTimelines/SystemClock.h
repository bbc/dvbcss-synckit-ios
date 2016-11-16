//
//  SystemClock.h
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

#import "ClockBase.h"
#import "MonotonicTime.h"





/**
 A root clock class that is based on `MonotonicTime` as the underlying time source
 */
@interface SystemClock : ClockBase


/**
 *  Default-value init method disallowed. Use initWithTickRate() method instead.
 *
 */
- (instancetype)init MSDesignatedInitializer(initWithTickRate:);

/**
 *  Initialise SystemClock instance with a tick rate
 *
 *  @param tickrate clock frequency in ticks per second
 *
 *  @return SystemClock instance
 */
- (id) initWithTickRate:(uint64_t) tickrate;


@end
