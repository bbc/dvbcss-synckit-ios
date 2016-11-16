//
//  SImpleAverager.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 15/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
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


@protocol OffsetAverager <NSObject>
/**
 Add a new item to averager's list
 @param offset A measurement to average
 @param dispersion  
 @return the moving average after adding this measurement
 */
-  (uint64_t)  put:(uint64_t) offset Dispersion:(float_t) dispersion;

/** get the current moving average */
- (uint64_t) getMovingAverage;


- (id) initWithCapacity:(int32_t)capacity__;

@end

/**
 A moving averager class for candidate offsets
 */
@interface SimpleAverager : NSObject <OffsetAverager>

/** list count */
@property (nonatomic, readonly) int32_t count;

/** max number of items in list*/
@property (nonatomic, readwrite) int32_t capacity;


@end



