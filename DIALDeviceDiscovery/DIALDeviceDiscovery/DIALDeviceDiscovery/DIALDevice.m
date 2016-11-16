//
//  DIAL_AppServiceEndpoint.m
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


#import "DIALDevice.h"

//------------------------------------------------------------------------------
#pragma mark - Global Constant Declarations
//------------------------------------------------------------------------------

NSString* const kDIALDevice_DIALServerKey              = @"DIALServer";
NSString* const kDIALDevice_DIALServiceKey             = @"DIALService";
NSString* const kDIALDevice_DIALVersionKey             = @"DIALVersion";
NSString* const kDIALDevice_DeviceNameKey              = @"DeviceName";
NSString* const kDIALDevice_AllowStopKey               = @"allowStop";
NSString* const kDIALDevice_StateKey                   = @"state";
NSString* const kDIALDevice_HbbTVApp2AppURLKey         = @"HbbTV_App2AppURL";
NSString* const kDIALDevice_HbbTVInterDevSyncURKey     = @"HbbTV_InterDevSyncURL";
NSString* const kDIALDevice_HbbTV_UserAgentKey         = @"HbbTV_UserAgent";
NSString* const kDIALDevice_HostKey                    = @"DIALHost";


//------------------------------------------------------------------------------
#pragma mark - DIALDevice (Interface Extension)
//------------------------------------------------------------------------------

@interface DIALDevice()

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  Accessor permission redefinition
 */

@property(readwrite, nonatomic) NSString *DIALServer;
@property(readwrite, nonatomic) NSString *DIALUniqueServiceName;
@property(readwrite, nonatomic) NSString *DIALVersion;
@property(readwrite, nonatomic) NSString *deviceName;
@property(readwrite, nonatomic) BOOL allowStop;
@property(readwrite, nonatomic) NSString* state;
@property(readwrite, nonatomic) NSString *HbbTV_App2AppURL;
@property(readwrite, nonatomic) NSString *HbbTV_InterDevSyncURL;
@property(readwrite, nonatomic) NSString *HbbTV_UserAgent;
@property(readwrite, nonatomic) NSString *DIALHost;
@property(readwrite, nonatomic) NSString *friendlyName;
@property(readwrite, nonatomic) NSString *manufacturer;
@property(readwrite, nonatomic) NSString *modelDesc;
@property(readwrite, nonatomic) NSString *modelName;
@property(readwrite, nonatomic) NSString *modelNumber;
@property(readwrite, nonatomic) NSString *serialNumber;
@property(readwrite, nonatomic) NSString *UDN;
@property(readwrite, nonatomic) NSString *presentationURL;

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------
#pragma mark - DIALDevice implementation
//------------------------------------------------------------------------------

@implementation DIALDevice
{
    
}

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------
- (id)initWithDictionary:(NSDictionary *) dict{
    
    self = [super init];
    if (self) {
        _DIALServer             = [[dict objectForKey:kDIALDevice_DIALServerKey] copy];
        _DIALUniqueServiceName  = [[dict objectForKey:kDIALDevice_DIALServiceKey] copy];
        _DIALVersion            = [[dict objectForKey:kDIALDevice_DIALVersionKey] copy];
        _deviceName             = [[dict objectForKey:kDIALDevice_DeviceNameKey] copy];
        _allowStop = [ [dict objectForKey:kDIALDevice_AllowStopKey] boolValue];
        _state = [[dict objectForKey:kDIALDevice_StateKey] copy];
        _HbbTV_App2AppURL = [[dict objectForKey:kDIALDevice_HbbTVApp2AppURLKey] copy];
        _HbbTV_InterDevSyncURL = [[dict objectForKey:kDIALDevice_HbbTVInterDevSyncURKey] copy];
        _HbbTV_UserAgent =  [[dict objectForKey:kDIALDevice_HbbTV_UserAgentKey] copy];
        _DIALHost = [[dict objectForKey:kDIALDevice_HostKey] copy];
        
        
        NSDictionary *deviceDesc = [dict objectForKey:@"DeviceDescription"];
        _friendlyName = [deviceDesc objectForKey:@"friendlyName"];
        _manufacturer = [deviceDesc objectForKey:@"manufacturer"];
        _modelDesc = [deviceDesc objectForKey:@"modelDescription"];
        _modelName = [deviceDesc objectForKey:@"modelName"];
        _modelNumber = [deviceDesc objectForKey:@"modelNumber"];
        _serialNumber = [deviceDesc objectForKey:@"serialNumber"];
        _UDN = [deviceDesc objectForKey:@"UDN"];
        _presentationURL = [deviceDesc objectForKey:@"presentationURL"];
        
        
    }
    return self;
}



//------------------------------------------------------------------------------
#pragma mark - Overridden NSObject methods
//------------------------------------------------------------------------------

-(id) copyWithZone: (NSZone *) zone
{
    DIALDevice* device = [[DIALDevice allocWithZone:zone]init];
    
    device.HbbTV_App2AppURL = [self.HbbTV_App2AppURL copy];
    device.HbbTV_InterDevSyncURL = [self.HbbTV_InterDevSyncURL copy];
    device.HbbTV_UserAgent = [self.HbbTV_UserAgent copy];
    device.DIALUniqueServiceName = [self.DIALUniqueServiceName copy];
    device.DIALServer = [self.DIALServer copy];
    device.DIALVersion = [self.DIALVersion copy];
    device.deviceName = [self.deviceName copy];
    device.allowStop = self.allowStop;
    device.state = [self.state copy];
    device.DIALHost = [self.DIALHost copy];
    
    device.friendlyName = [self.friendlyName copy];
    device.manufacturer = [self.manufacturer copy];
    device.modelDesc = [self.modelDesc copy];
    device.modelName = [self.modelName copy];
    device.modelNumber = [self.modelNumber copy];
    device.serialNumber = [self.serialNumber copy];
    device.UDN = [self.UDN copy];
    device.presentationURL = [self.presentationURL copy];
    
    
    return device;
    
}

//------------------------------------------------------------------------------

- (BOOL) isEqual:(DIALDevice*)object
{
    return (([object.UDN caseInsensitiveCompare:_UDN] == 0) &&
            ([object.DIALHost caseInsensitiveCompare:_DIALHost] == 0)
            );
    
    //    return (([object.DIALServer caseInsensitiveCompare:_DIALServer] == 0) &&
    //            ([object.DIALUniqueServiceName caseInsensitiveCompare:_DIALUniqueServiceName] == 0) &&
    //            ([object.DIALHost caseInsensitiveCompare:_DIALHost] == 0) &&
    //            ([object.HbbTV_App2AppURL caseInsensitiveCompare:_HbbTV_App2AppURL] == 0)
    //            );
}

//------------------------------------------------------------------------------
@end
