//
//  SSDPServiceDiscovery.h
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

//------------------------------------------------------------------------------
#pragma mark - Forward declarations
//------------------------------------------------------------------------------

@class SSDPServiceDiscovery;
@class SSDPService;


//------------------------------------------------------------------------------
#pragma mark - SSDPServiceDiscoveryDelegate protocol definition
//------------------------------------------------------------------------------
/**
 *   SSDPServiceDiscoveryDelegate protocol.
 */
@protocol SSDPServiceDiscoveryDelegate

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didNotStartBrowsingForServices:(NSError *)error;
//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didFindService:(SSDPService *)service;

//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didGetServiceUpdate:(SSDPService *)service;

//------------------------------------------------------------------------------

- (void) ssdpServiceDiscovery:(SSDPServiceDiscovery *)discoverer didRemoveService:(SSDPService *)service;

//------------------------------------------------------------------------------
@end


//------------------------------------------------------------------------------
#pragma mark - SSDPServiceDiscovery
//------------------------------------------------------------------------------
/**
 *   A class for discovering UPnP devices supporting a particular service type in the local network.
 *  This class listens for service advertisments on the UPnP multicast address/port and, maintains soft
 *  -state e.g. discovered service descriptions. All discovered services are held in an internal services 
 *  table. Changes in services table membership are notified to a delegate via the 
 *  SSDPServiceDiscoveryDelegate protocol.
 */
@interface SSDPServiceDiscovery : NSObject

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/** Type of UPnP service to discover. See SSDPServiceTypes for appropriate service names */
@property(readonly, nonatomic) NSString *serviceType;

/** Network interface to bind internal socket to */
@property(readonly, nonatomic) NSString *networkInterface;

/** A delegate object to receive callbacks*/
@property(assign, nonatomic) id<SSDPServiceDiscoveryDelegate> delegate;

//------------------------------------------------------------------------------
#pragma mark - Initialisation routines
//------------------------------------------------------------------------------

/**
 * Initialisation routines. To start listening to SSDP messages, call start()
 * @param service_type UPnP service type
 */
- (id) initWithServiceType:(NSString *)serviceType onInterface:(NSString *)networkInterface;

//------------------------------------------------------------------------------

- (id) initWithServiceType:(NSString *)serviceType;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Public methods
//------------------------------------------------------------------------------

/**
 * Start listening and handling SSDP messages.
 */
- (void) start;

//------------------------------------------------------------------------------

/**
 * Send an M-Search SSDP message on UPnP multicast address to look for available services
 */
- (void) launchSSDPSearch;

//------------------------------------------------------------------------------

/**
 * Stop this component from listening to service advertisements. Also stops ongoing service searches.
 To resume operations, call start() method.
 */
- (void) stop;

//------------------------------------------------------------------------------

/**
 * Look for a service in discovered services table.
 * @param usn unique service name, UPnP-stack- generated service name (containing the service GUID)
 * @return a SSDPService instance if lookup gets a hit, else nil.
 */
- (SSDPService*) serviceLookUp:(NSString*) usn;

//------------------------------------------------------------------------------

/**
 * Return all discovered services of the specified type
 * @param service_type, String representing the service type.
 * @return List of services
 */
- (NSArray*) servicesByType:(NSString*) service_type;

//------------------------------------------------------------------------------

/**
 * Return all discovered services
 */
- (NSArray*) getAllServices;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Class-level methods
//------------------------------------------------------------------------------

/**
 * Get info about all available network interfaces on the device.
 */
+ (NSDictionary *) availableNetworkInterfaces;

//------------------------------------------------------------------------------

@end
