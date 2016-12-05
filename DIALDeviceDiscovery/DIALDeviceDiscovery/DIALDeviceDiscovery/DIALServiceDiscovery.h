//
//  DIALServiceDiscovery.h
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


#import <Foundation/Foundation.h>
#import "SSDPService.h"
#import "SSDPServiceTypes.h"
#import "SSDPServiceDiscovery.h"
#import "DIALDevice.h"
#import "DIALDeviceDiscoveryTaskDelegate.h"
#import "DIALDeviceDiscoveryTask.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Constants, Keys Declarations
//------------------------------------------------------------------------------

/**
 *  string for HbbTV app name
 */
extern NSString * const kHbbTVApp;

/**
 *  DIAL's SSDP service type e.g. urn:dial-multiscreen-org:service:dial:1
 */
extern NSString * const SSDPServiceType_DIAL_MultiScreenOrgService1;


//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Notifications this components produces
 */
/**
 *  New device found notification
 */
extern NSString * const kNewDIALDeviceDiscoveryNotification;
/**
 *  Device expired notification
 */
extern NSString * const kDIALDeviceExpiryNotification;

/**
 *  Devices list has changed, reload notification
 */
extern NSString * const kRefreshDiscoveredDevicesNotification;


//------------------------------------------------------------------------------
#pragma mark - DIALServiceDiscovery Class Definition
//------------------------------------------------------------------------------
/**
 * The main class device discovery using the DIAL protocol. It discovers devices that run a DIAL server and HbbTV applications.
   In the first step of the discovery process, it uses the SSDPServiceDiscovery module to discover services of type DIAL_MultiScreenOrgService1. Subsequently, DIALAppDiscoveryTasks are created and launched to take over the remainder of the HbbTV app discovery: 1) the Device Description request and 2) the Application Information request.
  *
  *  The list of discovered apps can be obtained by calling the getDiscoveredDIALDevices() method.
  *
  *   Events produced: {DIALAppDiscoveryNotif, DIALAppExpiryNotif}
        1. "DIALAppDiscoveryNotif":  an NSNotification object containing a newly discovered HbbTV app, which is broadcast to other objects
        2. "DIALAppExpiryNotif": an NSNotification object for notifying that an HbbTV app host is off the network and the app has expired.
  *   
        Events required: None.
  */
@interface DIALServiceDiscovery: NSObject <SSDPServiceDiscoveryDelegate, DIALDeviceDiscoveryTaskDelegate>

/**
 *  The application running on the device discovered via DIAL.
 */
@property (nonatomic) NSString* applicationName;


//------------------------------------------------------------------------------
#pragma mark - Public methods
//------------------------------------------------------------------------------

/**
 *  Initialiser
 *
 *  @param appName name of application/service running on device
 *
 *  @return initialised instance
 */
- (id) initWithApplication:(NSString*) appName;

/**
 * Start the DIALServiceDiscovery component
 */
- (void) start;

//------------------------------------------------------------------------------

/**
 * Stop the DIALServiceDiscovery component
 */
- (void) stop;

//------------------------------------------------------------------------------

/**
 *  Get all devices discovered via the DIAL protocol till now.
 *
 *  @return array of DIALDevice objects
 */
- (NSArray*) getDiscoveredDIALDevices;

//------------------------------------------------------------------------------

/**
 *  Get all app discovery tasks currently in progress. To abort each task, the abort() methods can be invoked on each DIALDeviceDiscoveryTask object.
 *
 *  @return an array of DIALDeviceDiscoveryTask objects
 */
- (NSArray*) getCurrentDeviceDiscoveryTasks;

//------------------------------------------------------------------------------

@end

