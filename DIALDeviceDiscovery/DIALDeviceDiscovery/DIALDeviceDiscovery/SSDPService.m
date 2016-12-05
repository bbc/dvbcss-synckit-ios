//
//  SSDPService.m
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


#import "SSDPService.h"
#import <sys/time.h>
#import <SyncKitConfiguration/SyncKitGlobals.h>

//------------------------------------------------------------------------------
#pragma mark - SSDPService (Interface Extension)
//------------------------------------------------------------------------------


@interface SSDPService()

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  Accessor permission redefinition
 */
@property(readwrite, nonatomic) NSURL *location;
@property(readwrite, nonatomic) NSString *serviceType;
@property(readwrite, nonatomic) NSString *uniqueServiceName;
@property(readwrite, nonatomic) NSString *server;
@property (readwrite, nonatomic) NSString* serverIPAddress;


//------------------------------------------------------------------------------
#pragma mark - Local methods
//------------------------------------------------------------------------------

/**
 *  Calculate the difference between two timestamps
 *
 *  @param t1 a time value
 *  @param t2 a time value
 *
 *  @return difference in milliseconds
 */
long timevaldiff(struct timeval *t1, struct timeval *t2);

//------------------------------------------------------------------------------

@end


//------------------------------------------------------------------------------
#pragma mark - SSDPService implementation
//------------------------------------------------------------------------------

@implementation SSDPService{
    
    struct timeval expiryTime;
    SyncKitGlobals *config;
}

//------------------------------------------------------------------------------
#pragma mark - Initialiser methods
//------------------------------------------------------------------------------

- (id)initWithHeaders:(NSDictionary *)headers {
    self = [super init];
    if (self) {
        
        config = [SyncKitGlobals getInstance];
        _location = [NSURL URLWithString:[headers objectForKey:@"location"]];
        _serviceType = [headers objectForKey:@"st"];
        _uniqueServiceName = [headers objectForKey:@"usn"];
        _server = [headers objectForKey:@"server"];
        _serverIPAddress = [headers objectForKey:@"serverIPAddress"];
        
        config = [SyncKitGlobals getInstance];
        gettimeofday(&expiryTime, NULL);
        
        expiryTime.tv_sec = expiryTime.tv_sec + config.serviceTimeOutSecs;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (BOOL) isExpired{
    
    struct timeval now;
    gettimeofday(&now, NULL);
    
    if (timevaldiff(&now, &expiryTime) >=0)
        return YES;
    
    return NO;
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void) updateLifetime
{
    
    gettimeofday(&expiryTime, NULL);
    
    expiryTime.tv_sec = expiryTime.tv_sec + config.serviceTimeOutSecs;
}

//------------------------------------------------------------------------------

- (NSString *)description {
    return [NSString stringWithFormat:@"SSDPService<%@>", self.uniqueServiceName];
}

//------------------------------------------------------------------------------
#pragma mark - NSCopying Protocol methods
//------------------------------------------------------------------------------

-(id) copyWithZone: (NSZone *) zone
{
    SSDPService* serviceCopy = [[SSDPService allocWithZone:zone]init];
    
    serviceCopy.location = [_location copy];
    serviceCopy.serviceType = [_serviceType copy];
    serviceCopy.uniqueServiceName = [_uniqueServiceName copy];
    serviceCopy.server = [_server copy];
    serviceCopy.serverIPAddress = [_serverIPAddress copy];
    return serviceCopy;
    
}

//------------------------------------------------------------------------------




@end
