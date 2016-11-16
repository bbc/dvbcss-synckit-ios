//
//  DIALServiceDiscovery.m
//  
//
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


#import "DIALServiceDiscovery.h"
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SimpleLogger/SimpleLogger.h>



//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

// Notifications
NSString * const kNewDIALDeviceDiscoveryNotification   =   @"DIALDeviceDiscoveryNotif";
NSString * const kDIALDeviceExpiryNotification         =   @"DIALDeviceExpiryNotif";

//------------------------------------------------------------------------------
#pragma mark - Constants, Keys Declarations
//------------------------------------------------------------------------------

NSString * const kHbbTVApp = @"HbbTV";

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - DIALServiceDiscovery (Interface Extension)
//------------------------------------------------------------------------------

@interface DIALServiceDiscovery()

//------------------------------------------------------------------------------
#pragma mark - Local Properties
//------------------------------------------------------------------------------
/**
 *  config parameters source
 */
@property (nonatomic, readwrite) SyncKitGlobals* config;

//------------------------------------------------------------------------------

@end


//------------------------------------------------------------------------------
#pragma mark - DIALServiceDiscovery implementation
//------------------------------------------------------------------------------
@implementation DIALServiceDiscovery
{
    // SSDP search object
    SSDPServiceDiscovery *serviceRover;
    
    // list of discovery tasks in progress
    NSMutableArray *discoveryTaskList;
    
    // list of discovered hbbtv apps
    NSMutableArray *discoveredDevicesList;
    NSTimer* timer;
    
}

@synthesize config = _config;

//------------------------------------------------------------------------------
#pragma mark - Initialiser methods, Lifecycle methods
//------------------------------------------------------------------------------

- (id) init{
    self = [super init];
    if (self != nil) {
        // get a reference to object containing device constants
        _config = [SyncKitGlobals getInstance];
        assert(_config!=nil);
        
        discoveryTaskList = [[NSMutableArray alloc] init];
        discoveredDevicesList = [[NSMutableArray alloc] init];
        
        _applicationName = kHbbTVApp;
        
    }
    return self;
}

//------------------------------------------------------------------------------

- (id) initWithApplication:(NSString*) appName{
    self = [super init];
    if (self != nil) {
        // get a reference to object containing device constants
        _config = [SyncKitGlobals getInstance];
        assert(_config!=nil);
        
        discoveryTaskList = [[NSMutableArray alloc] init];
        discoveredDevicesList = [[NSMutableArray alloc] init];
        
        _applicationName = appName;
        
    }
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [self stop];
    serviceRover = nil;
    discoveredDevicesList = nil;
    discoveryTaskList = nil;
}


//------------------------------------------------------------------------------
#pragma mark - Public methods
//------------------------------------------------------------------------------

- (void) start{
    
    serviceRover = [[SSDPServiceDiscovery alloc] initWithServiceType:SSDPServiceType_DIAL_MultiScreenOrgService1];
    serviceRover.delegate = self;
    
    [serviceRover start]; // start listening for service adverts and responses to queries
    serviceRover.delegate = self;
    [serviceRover launchSSDPSearch]; // launch a query (M-Search message)
    
    // schedule a timer for removing expired
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:_config.DIAL_AppDiscoveryTimeoutSecs
                                             target:self selector:@selector(refreshTaskList:)
                                           userInfo:self repeats:YES];
    
}

//------------------------------------------------------------------------------

- (void) stop{
    [serviceRover stop];
    serviceRover = nil;
    
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    // cancel all current DIAL App discovery tasks
    for (DIALDeviceDiscoveryTask *task in discoveryTaskList) {
        [task abort];
    }
    [discoveryTaskList removeAllObjects];
    
    // delete all discovered apps
    for(DIALDevice* app in discoveredDevicesList)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDIALDeviceExpiryNotification object:[app copyWithZone:nil]];
    }
    [discoveredDevicesList removeAllObjects];
    
}

//------------------------------------------------------------------------------

- (NSArray*) getDiscoveredDIALDevices;{
    
    return discoveredDevicesList;
}

- (NSArray*) getCurrentDeviceDiscoveryTasks
{
    return discoveryTaskList;
}
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - Private methods
//------------------------------------------------------------------------------

- (DIALDevice*) LookUpExisting:(DIALDevice*) device
{
    for (DIALDevice* da  in discoveredDevicesList) {
        
        if ([da isEqual:device])
            return da;
    }
    
    return nil;
}

//------------------------------------------------------------------------------

- (DIALDevice*) DeviceLookUp:(SSDPService*) service
{
    for (DIALDevice* da  in discoveredDevicesList) {
        
        if ([da.DIALUniqueServiceName caseInsensitiveCompare:service.uniqueServiceName] == 0)
            return da;
    }
    
    return nil;
}

//------------------------------------------------------------------------------

- (void) refreshTaskList:(NSTimer*) timer{
    
    NSMutableArray *expiredTasks = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (DIALDeviceDiscoveryTask *task in discoveryTaskList) {
        if (task.isExpired){
            //[task abort];
            [expiredTasks addObject:task];
        }
    }
    
    // clean up expired tasks
    for (DIALDeviceDiscoveryTask *exp_task in expiredTasks)
        [discoveryTaskList removeObject:exp_task];
    
    [expiredTasks removeAllObjects];
    
    expiredTasks = nil;
}

//------------------------------------------------------------------------------
#pragma mark - DIALDeviceDiscoveryTaskDelegate methods
//------------------------------------------------------------------------------

- (void) DIALDeviceDiscovery:(DIALDeviceDiscoveryTask *)task didFindDevice:(DIALDevice *)device
{
    
    // NSLog(@"device %@", device);
    
    
    if ((![self LookUpExisting:device]) && (device.deviceName))
    {
        [discoveredDevicesList addObject:device];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:[device copyWithZone:nil] forKey:kNewDIALDeviceDiscoveryNotification];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewDIALDeviceDiscoveryNotification object:self userInfo:dict];
    }
    // remove finished task from list
    [discoveryTaskList removeObject:task];
}

//------------------------------------------------------------------------------

- (void) DIALDeviceDiscoveryAborted:(DIALDeviceDiscoveryTask*) task
{
    [discoveryTaskList removeObject:task];
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - SSDPServiceDiscoveryDelegate methods
//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didNotStartBrowsingForServices:(NSError *)error
{
    MWLogError(@"SSDP Service Discovery error: %@", error);
}

//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didFindService:(SSDPService *)service{
    
    MWLogDebug(@"DIALServiceDiscovery service found: %@", [service description]);
    
    DIALDevice* temp =nil;
    
    // check if we have already a corresponding DIAL_App object for this service
    
    temp = [self DeviceLookUp:service];
    
    if (temp)
    {
        // do nothing and return
    }else{
        // new service for a DIAL app found ... launch app discovery task
        DIALDeviceDiscoveryTask *task = [[DIALDeviceDiscoveryTask alloc] initWithService:service ApplicationName:_applicationName TaskDelegate:self];
        
        [discoveryTaskList addObject:task];
        
        
        // dispatch task
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [task start];
            }
        });
    }
    
}

//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didGetServiceUpdate:(SSDPService *)service
{
    
}

//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didRemoveService:(SSDPService *)service
{
    DIALDevice* temp =nil;
    
    // check if we have already a corresponding DIAL_App object for this service
    temp = [self DeviceLookUp:service];
    
    if (temp)
    {
        [discoveredDevicesList removeObject:temp];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:temp forKey:kDIALDeviceExpiryNotification];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDIALDeviceExpiryNotification object:self userInfo:dict];
        
    }
    
    // have we got any discovery tasks in progress on behalf of this service? If yes, then abort task
    
}






@end

