//
//  AppDelegate.h
//  SyncKitVideoSyncDemoApp
//
//  Created by Rajiv Ramdhany on 10/10/2016.
//  Copyright © 2016 Rajiv Ramdhany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DIALDeviceDiscovery/DIALDeviceDiscovery.h>
#import <SyncKitDelegate/SyncKitConfigurator.h>
#import <JSONModelFramework/JSONModelFramework.h>
#import <SimpleLogger/SimpleLogger.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


/**
 *  A reference to the SynckitConfigurator singleton, this singleton holds the DIAL discovery state
 */
@property (readonly,strong, nonatomic) SynckitConfigurator* configurator;

@end

