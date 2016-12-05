//
//  DIAL_AppServiceEndpoint.h
//  
//
//  Created by Rajiv Ramdhany on 08/12/2014.
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

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

FOUNDATION_EXPORT NSString* const kDIALDevice_DIALServerKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_DIALServiceKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_DIALVersionKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_DeviceNameKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_AllowStopKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_StateKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_HbbTVApp2AppURLKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_HbbTVInterDevSyncURKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_HbbTV_UserAgentKey;
FOUNDATION_EXPORT NSString* const kDIALDevice_HostKey ;

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - DIALDevice
//------------------------------------------------------------------------------

/**
 A class representing a device discovered  via the DIAL protocol.
 */
@interface DIALDevice : NSObject <NSCopying>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/** 
 HbbTV App host name 
 */
@property(readonly, nonatomic) NSString *DIALServer;

/** 
 UPnP-advertised service name 
 */
@property(readonly, nonatomic) NSString *DIALUniqueServiceName;

/** 
 dial version 
 */
@property(readonly, nonatomic) NSString *DIALVersion;

/** 
 device name
 */
@property(readonly, nonatomic) NSString *deviceName;

/** Can Apps on device be stopped? */
@property(readonly, nonatomic) BOOL allowStop;

/** Device app state */
@property(readonly, nonatomic) NSString* state;

/** HbbTV app to app websocket address */
@property(readonly, nonatomic) NSString *HbbTV_App2AppURL;

/** media sync starting websocket endpoint address */
@property(readonly, nonatomic) NSString *HbbTV_InterDevSyncURL;

/** user agent*/
@property(readonly, nonatomic) NSString *HbbTV_UserAgent;

/** IP address of app host*/
@property(readonly, nonatomic) NSString *DIALHost;

@property(readonly, nonatomic) NSString *friendlyName;
@property(readonly, nonatomic) NSString *manufacturer;
@property(readonly, nonatomic) NSString *modelDesc;
@property(readonly, nonatomic) NSString *modelName;
@property(readonly, nonatomic) NSString *modelNumber;
@property(readonly, nonatomic) NSString *serialNumber;
@property(readonly, nonatomic) NSString *UDN;
@property(readonly, nonatomic) NSString *presentationURL;


//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

- (id)initWithDictionary:(NSDictionary *) dict;

//------------------------------------------------------------------------------
#pragma mark - Overridden NSObject methods
//------------------------------------------------------------------------------

- (id) copyWithZone: (NSZone *) zone;


- (BOOL) isEqual:(DIALDevice* )object;


@end


