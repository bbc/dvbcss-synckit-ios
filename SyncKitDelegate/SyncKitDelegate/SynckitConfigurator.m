//
//  SynckitConfigurator.m
//  SyncKitDelegate
//
//  Created by Rajiv Ramdhany on 07/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import "SynckitConfigurator.h"
#import <SimpleLogger/SimpleLogger.h>
#import <SyncKitConfiguration/SyncKitConfiguration.h>



NSString* const kRefreshDiscoveredDevicesNotification =@"RefreshDiscoveredDevices";
NSString* const kTimelineSelector = @"urn:dvb:css:timeline:pts";


@interface SynckitConfigurator()

@property (readwrite, nonatomic) DIALServiceDiscovery   *DIALSDiscoveryComponent;

@end

@implementation SynckitConfigurator
{
    NSMutableDictionary *DIALAppLoadedComponents; // a dictionary to keep track of loaded components for each app
    SyncKitGlobals      *config;
    
}


+ (SynckitConfigurator *)getInstance {
    static SynckitConfigurator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SynckitConfigurator alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // create DIALAppLoadedComponents dictionary
        DIALAppLoadedComponents = [[NSMutableDictionary alloc]  init];
        
        config = [SyncKitGlobals getInstance];
        assert(config!=nil);
        
        MWLogInfo(@"SyncKitDelegate: Loading components .... ");
        
        self.DIALSDiscoveryComponent = [[DIALServiceDiscovery alloc] init];
        [self.DIALSDiscoveryComponent start];
        
        // // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DIALServiceDiscoveryNotifcationReceived:) name:nil object:self.DIALSDiscoveryComponent];
    }
    return self;
}

-(void) start
{
    
    
}


-(void) stop
{
    [self.DIALSDiscoveryComponent stop];
    
}


#pragma mark Event notification handlers
/** Handler for DIAL service discovery and update notifications */
- (void) DIALServiceDiscoveryNotifcationReceived:(NSNotification*) aNotification
{
    DIALDevice *app;
    
    //MWLogDebug(@"App Delegate: dial service discovery notification: %@ received.", [aNotification name]);
    
    if ([[aNotification name] caseInsensitiveCompare:kNewDIALDeviceDiscoveryNotification] == 0) {
        id temp = [[aNotification userInfo] objectForKey:kNewDIALDeviceDiscoveryNotification];
        
        if ([temp isKindOfClass: [DIALDevice class]] )
        {
            app = (DIALDevice*) temp;
            
            MWLogDebug(@"App Delegate: Master Device %@ found on network.", app.friendlyName);
            
            // do nothing, wait for user to select preferred TV (i.e. DIAL app)
        }
        
        
    } else if ([[aNotification name] caseInsensitiveCompare:kDIALDeviceExpiryNotification] == 0)
    {
        app = (DIALDevice*) [[aNotification userInfo] objectForKey:kDIALDeviceExpiryNotification];
        
        MWLogDebug(@"App Delegate: Master Device %@ no longer available.", app.friendlyName);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDiscoveredDevicesNotification object:nil];
        
        
    }
}


@end
