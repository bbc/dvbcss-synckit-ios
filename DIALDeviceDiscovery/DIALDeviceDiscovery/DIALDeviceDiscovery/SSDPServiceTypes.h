//
//  SSDPServiceTypes.h
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
//
#import <Foundation/Foundation.h>

//------------------------------------------------------------------------------
#pragma mark - Global constant declarations
//------------------------------------------------------------------------------

extern NSString *const SSDPServiceType_All; // ssdp:all

extern NSString *const SSDPServiceType_UPnP_RootDevice; // upnp:rootdevice

// UPnP Internet Gateway Device (IGD)
extern NSString *const SSDPServiceType_UPnP_InternetGatewayDevice1;     // urn:schemas-upnp-org:device:InternetGatewayDevice:1
extern NSString *const SSDPServiceType_UPnP_WANConnectionDevice1;       // urn:schemas-upnp-org:device:WANConnectionDevice:1
extern NSString *const SSDPServiceType_UPnP_WANDevice1;                 // urn:schemas-upnp-org:device:WANDevice:1
extern NSString *const SSDPServiceType_UPnP_WANCommonInterfaceConfig1;  // urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1
extern NSString *const SSDPServiceType_UPnP_WANIPConnection1;           // urn:schemas-upnp-org:service:WANIPConnection:1
extern NSString *const SSDPServiceType_UPnP_Layer3Forwarding1;          // urn:schemas-upnp-org:service:Layer3Forwarding:1

// UPnP A/V profile
extern NSString *const SSDPServiceType_UPnP_MediaServer1;           // urn:schemas-upnp-org:device:MediaServer:1
extern NSString *const SSDPServiceType_UPnP_MediaRenderer1;         // urn:schemas-upnp-org:device:MediaRenderer:1
extern NSString *const SSDPServiceType_UPnP_ContentDirectory1;      // urn:schemas-upnp-org:service:ContentDirectory:1
extern NSString *const SSDPServiceType_UPnP_ConnectionManager1;     // urn:schemas-upnp-org:service:ConnectionManager:1
extern NSString *const SSDPServiceType_UPnP_RenderingControl1;      // urn:schemas-upnp-org:service:RenderingControl:1
extern NSString *const SSDPServiceType_UPnP_AVTransport1;           // urn:schemas-upnp-org:service:AVTransport:1

// UPnP Microsoft A/V profile
extern NSString *const SSDPServiceType_Microsoft_MediaReceiverRegistrar1;    // urn:microsoft.com:service:X_MS_MediaReceiverRegistrar:1

// UPnP Sonos
extern NSString *const SSDPServiceType_UPnP_SonosZonePlayer1;    // urn:schemas-upnp-org:device:ZonePlayer:1

// UPnP DIAL
extern NSString *const SSDPServiceType_DIAL_MultiScreenOrgService1;