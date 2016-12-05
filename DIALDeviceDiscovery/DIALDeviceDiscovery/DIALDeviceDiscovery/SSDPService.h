//
//  SSDPService.h
//  Created by Rajiv Ramdhany on 01/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
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


//------------------------------------------------------------------------------
#pragma mark - SSDPService
//------------------------------------------------------------------------------

/**
 *  Class representing a UPnP service
 */
@interface SSDPService : NSObject <NSCopying>


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/** 
 service location 
 */
@property(readonly, nonatomic) NSURL *location;

/** service type, see SSDServiceTypes.h for examples */
@property(readonly, nonatomic) NSString *serviceType;

/** Unique service name */
@property(readonly, nonatomic) NSString *uniqueServiceName;

/* Service host */
@property(readonly, nonatomic) NSString *server;

/* Discovered service expiry status */
@property (readonly, nonatomic, getter=isExpired) BOOL expired;

/* Service host IP addr */
@property (readonly, nonatomic) NSString* serverIPAddress;


//------------------------------------------------------------------------------
#pragma mark - Initialiser methods
//------------------------------------------------------------------------------

/**
 *  Init service object with header fields from an HTTP response		
 *
 *  @param headers dictionary with header fields
 *
 *  @return initialised object
 */
- (id)initWithHeaders:(NSDictionary *)headers;

//------------------------------------------------------------------------------
#pragma mark - NSCopying Protocol methods
//------------------------------------------------------------------------------

- (id) copyWithZone: (NSZone *) zone;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------
/**
 *  Update the lifetime of this SSDP service
 */
- (void) updateLifetime;

//------------------------------------------------------------------------------
@end
