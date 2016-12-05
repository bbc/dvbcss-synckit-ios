//
//  SSDPServiceDiscovery.m

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
#import <UIKit/UIKit.h>
#import <pthread.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <AsyncSocket/AsyncSocket.h>
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SimpleLogger/SimpleLogger.h>
#import <SyncKitCollections/utils.h>

#import "SSDPServiceDiscovery.h"
#import "SSDPService.h"
#import "SSDPServiceTypes.h"


//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------

NSString *const SSDPMulticastGroupAddress   =   @"239.255.255.250";
int const SSDPMulticastUDPPort              =   1900;

NSString *const SSDPVersionString           =   @"CocoaSSDP/0.1.0";
NSString *const SSDPResponseStatusKey       =   @"HTTP-Status";
NSString *const SSDPRequestMethodKey        =   @"HTTP-Method";
NSString *const SSDPAdvertisementKey        =   @"HTTP-Notify";

NSString *const SSDPAlive                   =   @"ssdp:alive";
NSString *const SSDPByeBye                  =   @"ssdp:byebye";
NSString *const SSDPUpdate                  =   @"ssdp:update";


//------------------------------------------------------------------------------
#pragma mark - Data Structures Declarations
//------------------------------------------------------------------------------
/**
 SSDP message type
 */
typedef enum : NSUInteger {
    SSDPUnknownMessage,
    SSDPUnexpectedMessage,
    SSDPResponseMessage,
    SSDPSearchMessage,
    SSDPNotifyMessage,
} SSDPMessageType;

//------------------------------------------------------------------------------
#pragma mark - SSDPServiceDiscovery (Interface Extension)
//------------------------------------------------------------------------------

@interface SSDPServiceDiscovery(){
    
}

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

@property (nonatomic, weak) SyncKitGlobals* config;

//------------------------------------------------------------------------------
@end

//------------------------------------------------------------------------------
#pragma mark - SSDPServiceDiscovery implementation
//------------------------------------------------------------------------------
@implementation SSDPServiceDiscovery
{
    NSThread                *SSDPSearchThread;
    NSThread                *refreshServiceCacheThread;  // send request thread
    pthread_mutex_t         serviceCacheMutex;           // mutex to avoid race conditions on service table
    GCDAsyncUdpSocket       *_socket;
    NSMutableArray          *_services;
    NSMutableArray          *expiredServices;
    Boolean                 continue_loop;             // continue thread loop flag
}

//------------------------------------------------------------------------------
#pragma mark - Initialisation routines, Lifecycle methods
//------------------------------------------------------------------------------

- (id) initWithServiceType:(NSString *)serviceType onInterface:(NSString *)networkInterface {
    self = [super init];
    if (self) {
        _config = [SyncKitGlobals getInstance];
        _serviceType = [serviceType copy];
        _networkInterface = [networkInterface copy];
        _services = [[NSMutableArray alloc] init];
        expiredServices = [[NSMutableArray alloc] initWithCapacity:2];
        pthread_mutex_init(&serviceCacheMutex, NULL);
        
    }
    return self;
}

//------------------------------------------------------------------------------

- (id)initWithServiceType:(NSString *)serviceType {
    return [self initWithServiceType:serviceType onInterface:nil];
}

//------------------------------------------------------------------------------

- (id)init {
    return [self initWithServiceType:SSDPServiceType_All onInterface:nil];
}

//------------------------------------------------------------------------------

- (void) dealloc{
    [self stop];
    _services = nil;
    _serviceType = nil;
    _networkInterface = nil;
    _delegate = nil;
    _socket = nil;
    _config = nil;
}

//------------------------------------------------------------------------------
#pragma mark - Public methods
//------------------------------------------------------------------------------

- (void) start
{
    NSError *err = nil;
    
    if (_socket!=nil){
        [_socket close];
        _socket = nil;
    }
    
    _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_socket setIPv6Enabled:NO];
    
    
    
    NSDictionary *interfaces = [SSDPServiceDiscovery availableNetworkInterfaces];
    NSData *sourceAddress = nil;
    if( !sourceAddress ) sourceAddress = [[interfaces allValues] firstObject];
    
    if(![_socket bindToPort:SSDPMulticastUDPPort error:&err]) {
        [self _notifyDelegateWithError:err];
        
    }
    
    if(![_socket joinMulticastGroup:SSDPMulticastGroupAddress error:&err]) {
        [self _notifyDelegateWithError:err];
        
    }
    
    if(![_socket beginReceiving:&err]) {
        [self _notifyDelegateWithError:err];
    }
    
    // Start a thread for expiry of services
    continue_loop = true;
    
    // start with a clean service list
    [_services removeAllObjects];
    
    
    //Start a thread for search-message periodic transmission (discovery)
    SSDPSearchThread =  [[NSThread alloc]
                         initWithTarget:self
                         selector:@selector(periodicServiceSearchFunc)
                         object:nil];
    
    [SSDPSearchThread start];
    
    //Start a thread for checking service expiry
    refreshServiceCacheThread =  [[NSThread alloc]
                                  initWithTarget:self
                                  selector:@selector(refreshServicesCache)
                                  object:nil];
    
    [refreshServiceCacheThread start];
    
    MWLogInfo(@"SSDPServiceDiscovery component started. Joined multicast group %@ ... Listening on port %d", SSDPMulticastGroupAddress ,SSDPMulticastUDPPort);
}

//------------------------------------------------------------------------------

- (void)launchSSDPSearch {
    
    
    NSData *d = [[self _prepareSearchRequest] dataUsingEncoding:NSUTF8StringEncoding];
    
    [_socket sendData:d toHost:SSDPMulticastGroupAddress port:SSDPMulticastUDPPort withTimeout:-1 tag:11];
    MWLogDebug(@"SSDPServiceDiscovery component: searching for DIAL devices...");
    
}

//------------------------------------------------------------------------------

- (void)stop {
    
    // cancel a thread by allowing it to exit
    continue_loop = false;
    // allow thread to be deallocated
    refreshServiceCacheThread = nil;
    
    [_socket close];
    _socket = nil;
    
    if (_services.count > 0) [_services removeAllObjects];
    
}

//------------------------------------------------------------------------------

- (SSDPService*) serviceLookUp:(NSString*) usn{
    
    if (_services.count == 0) return nil;
    
    for (SSDPService* s in _services) {
        if ([s.uniqueServiceName caseInsensitiveCompare:usn] == NSOrderedSame)
            return s;
    }
    return nil;
}

//------------------------------------------------------------------------------

- (NSArray*) servicesByType:(NSString*) service_type
{
    NSMutableArray* matchedServices = [[NSMutableArray alloc] init];
    
    for (SSDPService *service in _services) {
        if ([service.serviceType caseInsensitiveCompare:service_type])
            [matchedServices addObject:service];
    }
    return matchedServices;
}

//------------------------------------------------------------------------------

- (NSArray*) getAllServices
{
    return _services;
}

//------------------------------------------------------------------------------
#pragma mark - Private methods
//------------------------------------------------------------------------------

/**
 *  A function to periodically launch an SSDP service search
 */
- (void) periodicServiceSearchFunc
{
    do{
        [self launchSSDPSearch];
        sleep(_config.ServiceSearchIntervalSecs);
        
    }while (continue_loop);
}

//------------------------------------------------------------------------------

/**
 *  Prepare an SSDP search request
 *
 *  @return a SSDP search request message as string
 */
- (NSString *)_prepareSearchRequest {
    NSString *userAgent = nil;
    NSDictionary *bundleInfos = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleExecutable = bundleInfos[(__bridge NSString *)kCFBundleExecutableKey] ?: bundleInfos[(__bridge NSString *)kCFBundleIdentifierKey];
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@) %@",
                 bundleExecutable,
                 (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: bundleInfos[(__bridge NSString *)kCFBundleVersionKey],
                 [[UIDevice currentDevice] model],
                 [[UIDevice currentDevice] systemVersion], SSDPVersionString];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@) %@", bundleExecutable,
                 bundleInfos[@"CFBundleShortVersionString"] ?: bundleInfos[(__bridge NSString *)kCFBundleVersionKey],
                 [[NSProcessInfo processInfo] operatingSystemVersionString], SSDPVersionString];
#endif
    
    return [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\n"
            "HOST: %@:%d\r\n"
            "MAN: \"ssdp:discover\"\r\n"
            "ST: %@\r\n"
            "MX: 3\r\n"
            "USER-AGENT: %@/1\r\n\r\n\r\n", SSDPMulticastGroupAddress, SSDPMulticastUDPPort, _serviceType, userAgent];
}

//------------------------------------------------------------------------------

/**
 *  A function to periodically refresh the Services cache
 */
- (void)refreshServicesCache {
    
    NSMutableArray *expiredServicesList = [[NSMutableArray alloc] init];
    do{
        sleep(_config.ServiceCacheRefreshIntervalSecs);
        
        pthread_mutex_lock(&serviceCacheMutex);
        //MWLogDebug(@"SSDPServiceDiscovery component: refreshing SSDP services table ... ");
        
        for (SSDPService *service in _services) {
            if (service.isExpired){
                [expiredServicesList addObject:service];
            }
        }
        
        // clean up expired tasks
        for (SSDPService *exp_service in expiredServicesList)
        {
            [_services removeObject:exp_service];
            [self _notifyDelegateWithRemovedService:exp_service];
            MWLogDebug(@"Service %@ expired ... removed from service cache.", exp_service.uniqueServiceName);
        }
        
        pthread_mutex_unlock(&serviceCacheMutex);
        
        [expiredServicesList removeAllObjects];
        
        
    }while (continue_loop);
}

//------------------------------------------------------------------------------

/**
 *  Get a host's IP address
 *
 *  @return IP address as string
 */
- (NSString *)sourceAddress {
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:[_socket localAddress]];
    return host;
}

//------------------------------------------------------------------------------

/**
 *  Parse headers from SSDP response message
 *
 *  @param message an SSDP Response Message
 *
 *  @return an NSDictionary populates with message header fileds and values
 */
- (NSMutableDictionary *)_parseHeadersFromMessage:(NSString *)message {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([a-z0-9-]+): *(.+)$"
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:nil];
    __block SSDPMessageType type = SSDPUnknownMessage;
    
    [message enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        
        // NSLog(@"LINE: %@", line);
        
        if( type == SSDPUnknownMessage ) {
            // First line describe type of message
            if([line isEqualToString:@"HTTP/1.1 200 OK"]) {
                type = SSDPResponseMessage;
                [headers setObject:@"200" forKey:SSDPResponseStatusKey];
            }
            else if([line isEqualToString:@"M-SEARCH * HTTP/1.1"]) {
                type = SSDPSearchMessage;
                [headers setObject:@"M-SEARCH" forKey:SSDPRequestMethodKey];
            }
            else if([line isEqualToString:@"NOTIFY * HTTP/1.1"]) {
                type = SSDPNotifyMessage;
                [headers setObject:@"NOTIFY" forKey:SSDPAdvertisementKey];
            }
            else {
                type = SSDPUnexpectedMessage;
            }
        }
        else {
            [regex enumerateMatchesInString:line options:0 range:NSMakeRange(0, line.length)
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     if( result.numberOfRanges == 3 ) {
                                         [headers setObject:[line substringWithRange:[result rangeAtIndex:2]]
                                                     forKey:[[line substringWithRange:[result rangeAtIndex:1]] lowercaseString]];
                                     }
                                 }];
        }
    }];
    return headers;
}


//------------------------------------------------------------------------------
#pragma mark - Class-level methods
//------------------------------------------------------------------------------


+ (NSDictionary *) availableNetworkInterfaces {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionary];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *ifa = NULL;
    
    // retrieve the current interfaces - returns 0 on success
    if( getifaddrs(&interfaces) == 0 ) {
        for( ifa = interfaces; ifa != NULL; ifa = ifa->ifa_next ) {
            if( (ifa->ifa_addr->sa_family == AF_INET) && !(ifa->ifa_flags & IFF_LOOPBACK) && !strncmp(ifa->ifa_name, "en", 2)) {
                NSData *data = [NSData dataWithBytes:ifa->ifa_addr length:sizeof(struct sockaddr_in)];
                NSString *if_name = [NSString stringWithUTF8String:ifa->ifa_name];
                [addresses setObject:data forKey:if_name];
            }
        }
        
        freeifaddrs(interfaces);
    }
    
    return addresses;
}




//------------------------------------------------------------------------------
#pragma mark - GCDAsyncUdpSocketDelegate methods
//------------------------------------------------------------------------------


- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    if( error ) {
        [self _notifyDelegateWithError:error];
    }
}

//------------------------------------------------------------------------------

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    SSDPService *service;
    SSDPService *temp = nil;
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if( msg )
    {
        //MWLogDebug(@"RECEIVED MESSAGE: %@", msg);
        
        NSDictionary *headers = [self _parseHeadersFromMessage:msg];
        
        // add service host IP address to dictionary
        [headers setValue: DisplayAddressForAddress(address) forKey:@"serverIPAddress"];
        
        if(( [headers objectForKey:SSDPResponseStatusKey] )  )
        {
            // received response message (reponse to M-SEARCH)
            // servicetype
            NSString *service_type = [[headers objectForKey:@"st"] stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceCharacterSet]];
            NSString *usn = [[headers objectForKey:@"usn"] stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
            
            // check for existing service, service cache lookup
            temp = [self serviceLookUp:usn];
            
            
            if (temp)
            {
                // service is in table, update lifetime
                pthread_mutex_lock(&serviceCacheMutex);
                [temp updateLifetime];
                pthread_mutex_unlock(&serviceCacheMutex);
            }else{
                
                // service not in service table, add service
                if ([service_type  caseInsensitiveCompare:_serviceType] == NSOrderedSame){
                    service = [[SSDPService alloc] initWithHeaders:headers];
                    
                    pthread_mutex_lock(&serviceCacheMutex);
                    // new service, add to table
                    [_services addObject:service];
                    pthread_mutex_unlock(&serviceCacheMutex);
                    
                    // Notify delegate with a copy of the service
                    [self _notifyDelegateWithFoundService:[service copyWithZone:nil]];
                }
            }
        }
        else if ( [headers objectForKey:SSDPAdvertisementKey] )
        {
            // received NOTIFY message (unsolicited service advertisement)
            NSString *NTS = [[headers objectForKey:@"nts"] stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
            
            // ssdp:alive,  ssdp:byebye NOTIFY messages are handled
            
            NSString *NT = [[headers objectForKey:@"nt"] stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
            
            NSString *usn = [[headers objectForKey:@"usn"] stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
            
            
            // add service, if it does not exist in our table
            if ([NTS caseInsensitiveCompare:SSDPAlive]== NSOrderedSame)
            {
                // check for existing service, service cache lookup
                temp = [self serviceLookUp:usn];
                
                if (temp)
                {
                    // service is in table, update lifetime
                    pthread_mutex_lock(&serviceCacheMutex);
                    [temp updateLifetime];
                    MWLogDebug(@"SSDPServiceDiscovery: service lifetime updated: %@", temp.uniqueServiceName);
                    pthread_mutex_unlock(&serviceCacheMutex);
                }else{
                    
                    // service not in service table, add service
                    if ([NT  caseInsensitiveCompare:_serviceType] == NSOrderedSame){
                        
                        service = [[SSDPService alloc] initWithHeaders:headers];
                        pthread_mutex_lock(&serviceCacheMutex);
                        // new service, add to table
                        [_services addObject:service];
                        pthread_mutex_unlock(&serviceCacheMutex);;
                        
                        // Notify delegate
                        [self _notifyDelegateWithFoundService:[service copyWithZone:nil]];
                        MWLogDebug(@"SSDPServiceDiscovery: service found by advertisement: %@", temp.uniqueServiceName);
                    }
                }
            }
            else if ([NTS caseInsensitiveCompare:SSDPUpdate]== NSOrderedSame) {
                
                // this is a service update, relaunch app discovery
                // check for existing service, service cache lookup
                temp = [self serviceLookUp:usn];
                
                
                if (temp)
                {
                    pthread_mutex_lock(&serviceCacheMutex);
                    [_services removeObject:temp];
                    pthread_mutex_unlock(&serviceCacheMutex);
                    [self _notifyDelegateWithRemovedService:service];
                }
                // add service to service table
                if ([NT  caseInsensitiveCompare:_serviceType] == NSOrderedSame){
                    service = [[SSDPService alloc] initWithHeaders:headers];
                    
                    // new service, add to table
                    pthread_mutex_lock(&serviceCacheMutex);
                    [_services addObject:service];
                    pthread_mutex_unlock(&serviceCacheMutex);
                    
                    // Notify delegate
                    [self _notifyDelegateWithFoundService:[service copyWithZone:nil]];
                }
                
            }else if ([NTS caseInsensitiveCompare:SSDPByeBye]== NSOrderedSame)
            {
                MWLogDebug(@"SSDPServiceDiscovery: byebye msg for : %@", usn);
                
                temp = nil;
                temp = [self serviceLookUp:usn];
                if (temp){
                    
                    pthread_mutex_lock(&serviceCacheMutex);
                    [_services removeObject:temp];
                    pthread_mutex_unlock(&serviceCacheMutex);
                    
                    [self _notifyDelegateWithRemovedService:[temp copyWithZone:nil]];
                }
            }
        }
    }
    else {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        MWLogDebug(@"SSDPServiceDiscovery component: unknown message received from %@:%hu", host, port);
    }
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - private notification methods
//------------------------------------------------------------------------------

- (void)_notifyDelegateWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [_delegate ssdpServiceDiscovery:self didNotStartBrowsingForServices:error];
        }
    });
}

//------------------------------------------------------------------------------

- (void)_notifyDelegateWithFoundService:(SSDPService *)service
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [_delegate ssdpServiceDiscovery:self didFindService:service];
        }
    });
}

//------------------------------------------------------------------------------

- (void)_notifyDelegateWithRemovedService:(SSDPService *)service
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [_delegate ssdpServiceDiscovery:self didRemoveService:service];
        }
    });
}

//------------------------------------------------------------------------------

- (void)_notifyDelegateWithServiceUpdate:(SSDPService *)service
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [_delegate ssdpServiceDiscovery:self didGetServiceUpdate:service];
        }
    });
}

//------------------------------------------------------------------------------
@end
