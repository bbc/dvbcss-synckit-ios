//
//  DIALDeviceDiscovery.h
//  DIALDeviceDiscovery
//
//  Created by Rajiv Ramdhany on 04/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
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


#import <UIKit/UIKit.h>

//! Project version number for DIALDeviceDiscovery.
FOUNDATION_EXPORT double DIALDeviceDiscoveryVersionNumber;

//! Project version string for DIALDeviceDiscovery.
FOUNDATION_EXPORT const unsigned char DIALDeviceDiscoveryVersionString[];


/**
 * This dynamic library performs HbbTV app discovery using the DIAL protocol. In the first step of the discovery process, it uses the SSDPServiceDiscovery module to discover services of type DIAL_MultiScreenOrgService1. Subsequently, DIALAppDiscoveryTasks are created and launched to take over the remainder of the HbbTV app discovery: 1) the Device Description request and 2) the Application Information request.
 *
 * 
 *   Events produced:
 1. "DIALDeviceDiscoveryNotif":  an NSNotification object containing a newly discovered DIAL Device which is broadcast to other objects
 2. "DIALDeviceExpiryNotif": an NSNotification object for notifying that an HbbTV app host is off the network and the app has expired.
 *
 Events required: None.
 */



#import <DIALDeviceDiscovery/DIALServiceDiscovery.h>
#import <DIALDeviceDiscovery/SSDPServiceTypes.h>
#import <DIALDeviceDiscovery/SSDPService.h>
#import <DIALDeviceDiscovery/SSDPServiceDiscovery.h>
#import <DIALDeviceDiscovery/DIALDevice.h>
#import <DIALDeviceDiscovery/DIALDeviceDiscoveryTask.h>
#import <DIALDeviceDiscovery/DIALDeviceDiscoveryTaskDelegate.h>
#import <DIALDeviceDiscovery/DeviceDescription.h>