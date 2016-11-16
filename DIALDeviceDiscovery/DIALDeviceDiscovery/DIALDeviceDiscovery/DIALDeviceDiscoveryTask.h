//
//  DIALDeviceDiscoveryTask.h
//
//  Created by Rajiv Ramdhany on 09/12/2014.
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
#import "SSDPServiceTypes.h"
#import "SSDPService.h"
#import "DIALDevice.h"
#import "DIALServiceDiscovery.h"
#import "DIALDeviceDiscoveryTaskDelegate.h"

//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------


extern NSString *const SSDPServiceType_DIAL_MultiScreenOrgService1;

//------------------------------------------------------------------------------

/**
 The states of a DIALDeviceDiscoveryTask
 */
enum DIALDeviceDiscoveryTaskStatus{
    /**
     *  New service found state
     */
    kDIALDeviceDiscovery_NewServiceFound = 0,
    /**
     *  SSDP missing header state
     */
    kDIALDeviceDiscovery_SSDPMissingHeader ,
    /**
     *  Looking up Device Description
     */
    kDIALDeviceDiscovery_DeviceDescriptionLookUp ,
    kDIALDeviceDiscovery_HTTP404Error,
    kDIALDeviceDiscovery_RESTServiceURLFound,
    kDIALDeviceDiscovery_RESTServiceURLNotFound,
    kDIALDeviceDiscovery_TaskAbort,
    kDIALDeviceDiscovery_DIALAppDescriptionFound,
    kDIALDeviceDiscovery_DIALAppDescriptionNotFound,
    kDIALDeviceDiscovery_IncorrectMIMEType
};

//------------------------------------------------------------------------------
#pragma mark - Other  Declarations
//------------------------------------------------------------------------------
@protocol DIALDeviceDiscoveryTaskDelegate;



//------------------------------------------------------------------------------
#pragma mark - DIALDeviceDiscoveryTask
//------------------------------------------------------------------------------
/**
 * Class to represent an device discovery task. A task is launched when a service of this type "urn:dial-multiscreen-org:service:dial:1" is discovered via SSDP (by the SSDPServiceDiscovery module).
   An M-SEARCH request sent by the SSDPServiceDiscovery object results in a response containing a LOCATION header 
 containing an absolute HTTP URL for the UPnP description of the root device. 
 
 On receipt of the M-SEARCH response, a DIALDeviceDiscoveryTask is created and it issues an HTTP GET request to the URL received in the LOCATION header of the M-SEARCH response.
 
 On receipt of a valid HTTP GET for the device description, a DIAL server SHALL respond with an HTTP response containing the UPnP device description. If the request is successful, the HTTP response contains an additional header field, Application­URL. This URL identifies the DIAL REST Service and is referred to as the DIAL REST Service URL.
 
 The DIAL REST service represents applications (for example Netflix, YouTube, etc.) as resources identified by URLs. Operations related to an application are performed by issuing HTTP requests against the URL for that application. This URL is known as an Application Resource URL.
 The Application Resource URL for an application is constructed by concatenating the DIAL REST Service URL, a single slash character (‘/’) and the Application Name (See appName property).
 
 The progress of the discovery task can be checked via the **status** property.
 
 */
@interface DIALDeviceDiscoveryTask : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------


/**
 *  the UPnP DIAL service that triggered this task
 */
@property (nonatomic, readonly) SSDPService* service;

// DIAL REST Service URL
@property (nonatomic, readonly) NSString *application_URL; // DIAL REST Service

// name of app running on DIAL device e.g. "HbbTV"
@property (nonatomic, readonly) NSString *appName;

// Result of discovery task
@property (nonatomic, readonly) DIALDevice *dialDevice;

/**
 *  progress of discovery task
 */
@property (nonatomic, readonly) enum DIALDeviceDiscoveryTaskStatus status;

/**
 *  has this device expired?
 */
@property (nonatomic, readonly, getter=isExpired) BOOL expired;

/**
 *  this discovery task's delegate object for receiving callbacks
 */
@property (nonatomic, readonly) id<DIALDeviceDiscoveryTaskDelegate> devDiscTaskdelegate;

//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

/**
 * Initialisation routine. Launch DIAL REST Service lookup by sending HTTP GET request
 * on location URL (from service reply)
 */
- (id) initWithService:(SSDPService*) service_ ApplicationName:(NSString*) app_name TaskDelegate:(id<DIALDeviceDiscoveryTaskDelegate>) delegate;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------
/**
 *  Start this task.
 */
- (void) start;

//------------------------------------------------------------------------------

/**
 *  Abort this task.
 */
- (void) abort;

//------------------------------------------------------------------------------
@end


