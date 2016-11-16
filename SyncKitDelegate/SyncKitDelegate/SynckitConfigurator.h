//
//  SynckitConfigurator.h
//  SyncKitDelegate
//
//  Created by Rajiv Ramdhany on 07/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DIALDeviceDiscovery/DIALDeviceDiscovery.h>
/**
 *  An optional configurator component whose role is to load all components required to enable
 *  TV discovery, wallclock synchronisation, content identification and timeline synchronisation.
 *  This component also keeps track of the current TV device being synchronised to and other user-selected
 *  artifacts. 
 *  
 *  @warn: this component has now been deprecated but is still included as it is used in some demo applications.
 *  
 *  Events required: {}
 */
@interface SynckitConfigurator : NSObject

/** Component for performing UPnP/SSDP DIAL services lookup */
@property (readonly, nonatomic) DIALServiceDiscovery* DIALSDiscoveryComponent;

/** A discovered TV service (an app on TV discovered via DIAL), user has selected for sync'ing with */
@property (readwrite, nonatomic) DIALDevice *currentDIALdevice;

/**
 *  returns the singleton instance of this class
 *
 *  @return the single SynckitConfigurator instance.
 */
+ (SynckitConfigurator *)getInstance;


- (void) start;


- (void) stop;



@end

/** Event notification for UIViewController instances to refresh their views due to a change in the discovered TV-list */
extern NSString* const kRefreshDiscoveredDevicesNotification;