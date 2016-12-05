//
//  DeviceDescription.h
//  
//
//  Created by Rajiv Ramdhany on 12/08/2015.
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


#import <Foundation/Foundation.h>

/**
 *  A description of a device discovered via UPnP (SSDP). A DeviceDescription instance is created
 *  
 */
@interface DeviceDescription : NSObject 

/**
 *  Device type
 */
@property(readonly, nonatomic) NSString *deviceType;

/**
 *  Friendly name
 */
@property(readonly, nonatomic) NSString *friendlyName;

/**
 *  Manufacturer
 */
@property(readonly, nonatomic) NSString *manufacturer;
@property(readonly, nonatomic) NSString *manufacturerURL;
@property(readonly, nonatomic) NSString *modelDesc;
@property(readonly, nonatomic) NSString *modelName;
@property(readonly, nonatomic) NSString *modelNumber;
@property(readonly, nonatomic) NSString *modelURL;
@property(readonly, nonatomic) NSString *serialNumber;
@property(readonly, nonatomic) NSString *UDN;
@property(readonly, nonatomic) NSString *presentationURL;

@end



extern NSString* const kDeviceDesc_DeviceType;
extern NSString* const kDeviceDesc_FriendlyName;
extern NSString* const kDeviceDesc_Manufacturer;
extern NSString* const kDeviceDesc_ManufacturerURL;
extern NSString* const kDeviceDesc_ModelDescription;
extern NSString* const kDeviceDesc_ModelName;
extern NSString* const kDeviceDesc_ModelNumber;
extern NSString* const kDeviceDesc_ModelURL;
extern NSString* const kDeviceDesc_SerialNumber;
extern NSString* const kDeviceDesc_UDN ;
extern NSString* const kDeviceDesc_PresentationURL;
