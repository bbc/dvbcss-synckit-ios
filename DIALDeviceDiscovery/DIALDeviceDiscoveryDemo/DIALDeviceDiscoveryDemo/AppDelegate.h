//
//  AppDelegate.h
//  DIALDeviceDiscoveryDemo
//
//  Created by Rajiv Ramdhany on 06/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <DIALDeviceDiscovery/DIALDeviceDiscovery.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** Component for performing UPnP/SSDP DIAL services lookup */
@property (readonly, nonatomic) DIALServiceDiscovery* DIALSDiscoveryComponent;

/** A discovered DIAL service, user has selected for sync'ing with */
@property (readwrite, nonatomic) DIALDevice *currentDIALDevice;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

