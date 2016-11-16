//
//  utils.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 13/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#ifndef WallClockClient_utils_h
#define WallClockClient_utils_h
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <CFNetwork/CFNetwork.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#include <netdb.h>
#import <Foundation/Foundation.h>
#include <mach/mach_time.h>

extern uint64_t getTimeInNanoseconds();

extern int64_t getUptimeInMilliseconds();

/** Returns a dotted decimal string for the specified address (a (struct sockaddr)
  within the address NSData).*/
extern NSString * DisplayAddressForAddress(NSData * address);

/** Returns a human readable string for the given data.*/

extern NSString * DisplayStringFromData(NSData *data);

extern NSString * DisplayHexStringFromData(NSData *data);

extern NSString * DisplayErrorFromError(NSError *error);

#endif