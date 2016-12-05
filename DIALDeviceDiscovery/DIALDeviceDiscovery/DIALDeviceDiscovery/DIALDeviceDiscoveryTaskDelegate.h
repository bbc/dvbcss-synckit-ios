//
//  DIALDeviceDiscoveryTaskDelegate.h
//  
//
//  Created by Rajiv Ramdhany on 10/12/2014.
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
#import "DIALDevice.h"
#import "DIALDeviceDiscoveryTask.h"

@class DIALDeviceDiscoveryTask;

/**
 *  Protocol for DIALDeviceDiscoveryTask delegate object. Apart from this delegate mechanism, device-discovery is made known to observers via notifications (the 'DIALDeviceDiscoveryNotif' notification). 
 */
@protocol DIALDeviceDiscoveryTaskDelegate <NSObject>

/**
 *  Callback triggered when a device was found
 *
 *  @param task   the DIALDiscoveryTask that found the device
 *  @param device the discovered device as a DIALDevice instance
 */
- (void) DIALDeviceDiscovery:(DIALDeviceDiscoveryTask *) task didFindDevice:(DIALDevice*) device;

/**
 *  Callback triggered when as a DIALDeviceDiscoveryTask was aborted.
 *
 *  @param task the aborted DIALDeviceDiscoveryTask
 */
- (void) DIALDeviceDiscoveryAborted:(DIALDeviceDiscoveryTask *) task;

@end
