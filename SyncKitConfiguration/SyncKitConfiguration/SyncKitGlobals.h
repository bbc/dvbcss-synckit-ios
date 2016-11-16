//
//  DeviceGlobals.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 20/08/2014.
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


/**
 A singleton to load device constants and make them available globally to other objects.
 */
@interface SyncKitGlobals : NSObject


@property (atomic, readwrite) int64_t ClientWCPrecisionInNanos;
@property (atomic, readwrite) uint32_t ClientWCFrequencyError;  // in ppm
@property (atomic, readwrite) uint32_t CachedWCREQTimeOutUSecs;  // in microseconds
@property (atomic, readwrite) uint32_t CachedWCRESPTimeOutUSecs;  // in microseconds
@property (atomic, readwrite) uint32_t WCREQSendPeriodUSecs;  // in microseconds
@property (atomic, readwrite) uint32_t SyncAccuracyTargetMilliSecs;  // in millisecs


// these are set upon receiving first Wall Clock Sync response message from server
// since they are not likely to change
@property (atomic, readwrite) uint64_t ServerWCPrecisionInNanos;
@property (atomic, readwrite) uint32_t ServerWCFrequencyError;  // in ppm

@property (atomic, readwrite) uint32_t SocketSelectTimeOutUSecs;


@property (atomic, readwrite) NSString* ciiURL;
@property (atomic, readwrite) NSString* mrsURL;
@property (atomic, readwrite) NSString* wcURL;
@property (atomic, readwrite) NSString* tsURL;
@property (atomic, readwrite) NSString* teURL;
@property (atomic, readwrite) NSString* tweetURL;
@property (atomic, readwrite) uint32_t serviceTimeOutSecs;

@property (atomic, readwrite) uint32_t DIAL_AppDiscoveryTimeoutSecs;
@property (atomic, readwrite) uint32_t ServiceCacheRefreshIntervalSecs;
@property (atomic, readwrite) uint32_t ServiceSearchIntervalSecs;
@property (atomic, readwrite) uint32_t WCRTTThresholdMSecs;

+ (SyncKitGlobals *)getInstance;

@end
