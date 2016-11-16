//
//  utils.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 13/08/2014.
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

#ifndef SyncKitCollections_utils_h
#define SyncKitCollections_utils_h
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <CFNetwork/CFNetwork.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#include <netdb.h>
#include <mach/mach_time.h>
#import <Foundation/Foundation.h>
/**
 *  get current host time in nanoseconds
 *
 *  @return current host time in nanoseconds
 */
extern uint64_t getTimeInNanoseconds();

/**
 *   get current host time in milliseconds
 *
 *  @return current host time in milliseconds
 */
extern int64_t getUptimeInMilliseconds();

/**
 *  calculate  difference between two timeval timestamps
 *
 *  @param t1 a struct timeval parameter
 *  @param t2 a struct timeval parameter
 *
 *  @return difference between two timeval timestamps
 */
extern long timevaldiff(struct timeval *t1, struct timeval *t2);


/**
 *  Returns a dotted decimal string for the specified address (a (struct sockaddr) within the address NSData).
 *
 *  @param address an address structure
 *
 *  @return string
 */
extern NSString * DisplayAddressForAddress(NSData * address);



/**
 *  Returns a human readable string for the given data.
 *
 *  @param data binary data
 *
 *  @return string
 */
extern NSString * DisplayStringFromData(NSData *data);

/**
 *  Returns hex representation of contents of 'data'
 *
 *  @param data binary data
 *
 *  @return hex string
 */
extern NSString * DisplayHexStringFromData(NSData *data);

/**
 *  Given an NSError, returns a short error string that we can print, handling
 *  some special cases.
 *
 *  @param error an NSError instance
 *
 *  @return string
 */
extern NSString * DisplayErrorFromError(NSError *error);




#endif