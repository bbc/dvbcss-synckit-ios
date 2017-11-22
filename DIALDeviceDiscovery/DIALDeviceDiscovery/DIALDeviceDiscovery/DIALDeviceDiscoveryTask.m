//
//  DIALDeviceDiscoveryTask.m
//  
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


#include <sys/time.h>
#import <SimpleLogger/SimpleLogger.h>
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SyncKitCollections/SyncKitCollections.h>
#import "DIALDeviceDiscoveryTask.h"
#import "DeviceDescription.h"



//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - DIALDeviceDiscoveryTask (Interface Extension)
//------------------------------------------------------------------------------

@interface DIALDeviceDiscoveryTask()

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  Accessor permission redefinition
 */
@property (nonatomic, readwrite) SSDPService* service;
@property (nonatomic, readwrite) NSString *application_URL; // DIAL REST Service
@property (nonatomic, readwrite) NSString *appName;
@property (nonatomic, readwrite) DIALDevice *dialDevice;
@property (nonatomic, readwrite) enum DIALDeviceDiscoveryTaskStatus status;

//------------------------------------------------------------------------------

/**
 *  Task status
 */
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancel; //

/**
 *  Reference to configuration parameter object
 */
@property (nonatomic, weak) SyncKitGlobals *config;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - class methods
//------------------------------------------------------------------------------

/**
 *  Get HbbTV Service Description XML document from Application-URL
 */
+(void)GetHbbTVAppXMLInfo:url withCompletionHandler:(void(^)(NSData *data))completionHandler;

//------------------------------------------------------------------------------

@end



//------------------------------------------------------------------------------
#pragma mark - DIALDeviceDiscoveryTask implementation
//------------------------------------------------------------------------------

@implementation DIALDeviceDiscoveryTask
{
    NSURLConnection *http_connection;
    NSHTTPURLResponse *http_response;
    
    
    NSXMLParser *xmlParser;
    NSMutableDictionary *dictTempDataStorage;
    NSMutableDictionary *deviceDescDict;
    NSMutableString *foundElementValue;
    NSString *currentElement;
    
    struct timeval expiryTime;
    
    NSDictionary* headers;
}

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

/**
 * Initialisation routine. Launch DIAL REST Service lookup by sending HTTP GET request
 * on location URL (from service reply)
 */
- (id) initWithService:(SSDPService*) service_ ApplicationName:(NSString*) app_name TaskDelegate:(id<DIALDeviceDiscoveryTaskDelegate>) delegate
{
    self = [super init];
    if (self != nil) {
        
        _config  = [SyncKitGlobals getInstance];
        assert(_config!=nil);
        
        _service = service_;
        _appName = app_name;
        _devDiscTaskdelegate = delegate;
        
        
        _status = kDIALDeviceDiscovery_NewServiceFound;
        _cancel = NO;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------


- (BOOL) isCancelled{
    return _cancel;
}

//------------------------------------------------------------------------------

/**
 * Task has expired?
 */
- (BOOL) isExpired{
    
    struct timeval now;
    gettimeofday(&now, NULL);
    
    if (timevaldiff(&now, &expiryTime) >=0)
        return YES;
    
    return NO;
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void) start{
    
    
    // STEP ONE: Create and send  the DIAL REST Service lookup HTTP request. Obviate the use of the local cache to fulfill this HTTP request.
    NSURLRequest *request = [NSURLRequest requestWithURL:_service.location cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    http_connection = conn;
    assert(http_connection != nil);
    
    // update task status
    _status = kDIALDeviceDiscovery_DeviceDescriptionLookUp;
    
    gettimeofday(&expiryTime, NULL);
    expiryTime.tv_sec += _config.DIAL_AppDiscoveryTimeoutSecs;
    
}

//------------------------------------------------------------------------------

/**
 * Abort this ongoing task
 */
- (void) abort
{
    _cancel = YES;
    
    // cleanup
    if (http_connection){
        [http_connection cancel];
        http_connection = nil;
    }
    
    http_response = nil;
    self.dialDevice = nil;
    
    [_devDiscTaskdelegate DIALDeviceDiscoveryAborted:self];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - NSURLConnection Delegate methods
//------------------------------------------------------------------------------

/**
 * Delegate method of NSURLConnection. Parse response received after a DIAL REST Service lookup HTTP GET request was sent.
 * Receive the UPnP device description containing an Application-URL header (the DIAL REST Service URL)
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // STEP TWO: Receive the UPnP device description containing an Application-URL header (the DIAL REST Service URL)
    
    http_response = (NSHTTPURLResponse*) response;
    
    if (http_response.statusCode == 200)
    {
        
        headers = [http_response allHeaderFields];
        
        _application_URL = [headers objectForKey:@"Application-URL"];
        //MWLogDebug(@"Application-URL:%@", _application_URL);
        
        if (_application_URL)
            _status = kDIALDeviceDiscovery_RESTServiceURLFound;
        else
        {
            _status = kDIALDeviceDiscovery_RESTServiceURLNotFound;
            [self abort];
        }
        
        // check MIME Type for Device Description
        if ([http_response.MIMEType caseInsensitiveCompare:@"text/xml"]!=0) {
            _status = kDIALDeviceDiscovery_IncorrectMIMEType;
        }
        
    }else if ((http_response.statusCode == 404))
    {
        _status = kDIALDeviceDiscovery_HTTP404Error;
        [self abort];
    }
    
}

//------------------------------------------------------------------------------

/**
 *   Delegate method of NSURLConnection
 *
 *  @param connection connection
 *  @param data       Device description in XML
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // data contains the device description.
    // parse data
    
//    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    
    //NSLog(@"Device description: %@", str);
    
    
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    [xmlParser setShouldProcessNamespaces:YES];
    
    xmlParser.delegate = self;
    
    // Initialize the mutable string that we'll use during parsing.
    foundElementValue = [[NSMutableString alloc] init];
    
    // Start parsing.
    [xmlParser parse];
    
    
}

//------------------------------------------------------------------------------

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

//------------------------------------------------------------------------------

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    // STEP THREE: use Application-URL (DIAL REST Service URL) to get HbbTV app information
    if ((_application_URL) && (!_cancel))
    {
        // get the hbbtv app URL
        NSString *dial_rest_service;
        if ([_application_URL hasSuffix:@"/"]) {
            dial_rest_service = [NSString stringWithFormat:@"%@%@", _application_URL, _appName];
        } else {
            dial_rest_service = [NSString stringWithFormat:@"%@/%@", _application_URL, _appName];
        }
        NSURL *dial_rest_url = [NSURL URLWithString:dial_rest_service];
        
        // get DIAL HbbTV app information XML document.
        [DIALDeviceDiscoveryTask GetHbbTVAppXMLInfo:dial_rest_url withCompletionHandler:^(NSData *data) {
            // Make sure that there is data.
            if (data != nil) {
                
                // update task status => dial app desc found
                _status = kDIALDeviceDiscovery_DIALAppDescriptionFound;
                
//                NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
                
                //MWLogDebug(@"DIALDeviceDiscoveryTask.connectionDidFinishLoading() dial hbbtv app: %@", str);
                
                xmlParser = [[NSXMLParser alloc] initWithData:data];
                xmlParser.delegate = self;
                
                // Initialize the mutable string that we'll use during parsing.
                foundElementValue = [[NSMutableString alloc] init];
                
                // Start parsing.
                [xmlParser parse];
            }else{
                // update task status, dial app desc not found
                _status = kDIALDeviceDiscovery_DIALAppDescriptionNotFound;
                [self abort];
            }
        }];
    }
    
    http_response =nil;
    
}

//------------------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    MWLogError(@"Application-URL Discovery error: %@", error);
    
    _status = kDIALDeviceDiscovery_RESTServiceURLNotFound;
    
    http_connection = nil;
    http_response = nil;
    
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Class methods
//------------------------------------------------------------------------------

+(void)GetHbbTVAppXMLInfo:(NSURL*) url withCompletionHandler:(void(^)(NSData *data))completionHandler{
    // Instantiate a session configuration object.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Instantiate a session object.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            MWLogError(@"%@", [error localizedDescription]);
        }
        else{
            // If no error occurs, check the HTTP status code.
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            // If it's other than 200, then show it on the console.
            if (HTTPStatusCode != 200) {
                MWLogError(@"HTTP status code = %d", HTTPStatusCode);
            }
            
            // Call the completion handler with the returned data on the main thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data);
            }];
        }
        [session finishTasksAndInvalidate];
    }];
    
    // Resume the task.
    [task resume];
    
    
}
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - NSXMLParserDelegate methods
//------------------------------------------------------------------------------


-(void)parserDidStartDocument:(NSXMLParser *)parser{
    
}

//------------------------------------------------------------------------------

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    // When the parsing has been finished then simply reload the table view.
    //[self.tblNeighbours reloadData];
}


-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    MWLogError(@"DIALDeviceDiscoveryTask.connectionDidFinishLoading %@", [parseError localizedDescription]);
    [self abort];
    
}

//------------------------------------------------------------------------------

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"device"]) {
        deviceDescDict = [[NSMutableDictionary alloc] init];
        
    }
    
    
    // If the current element name is equal to "geoname" then initialize the temporary dictionary.
    if ([elementName isEqualToString:@"service"]) {
        dictTempDataStorage = [[NSMutableDictionary alloc] init];
        [dictTempDataStorage setObject:deviceDescDict forKey:@"DeviceDescription"];
        if (_service.server) [dictTempDataStorage setObject:_service.server  forKey:kDIALDevice_DIALServerKey];
        [dictTempDataStorage setObject:_service.uniqueServiceName  forKey:kDIALDevice_DIALServiceKey];
        
        NSString *dialVer = [attributeDict objectForKey:@"dialVer"];
        
        if (dialVer)
            [dictTempDataStorage setObject:dialVer  forKey:kDIALDevice_DIALVersionKey];
    }else if ([elementName isEqualToString:@"options"]){
        NSString *allow_stop = [attributeDict objectForKey:@"allowStop"];
        
        if (allow_stop)
            [dictTempDataStorage setObject:allow_stop  forKey:kDIALDevice_AllowStopKey];
    }
    
    // Keep the current element.
    currentElement = elementName;
}

//------------------------------------------------------------------------------

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    
    if ([elementName isEqualToString:kDeviceDesc_FriendlyName]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_FriendlyName];
    }else if ([elementName isEqualToString:kDeviceDesc_Manufacturer]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_Manufacturer];
    }else if ([elementName isEqualToString:kDeviceDesc_ModelDescription]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_ModelDescription];
    }if ([elementName isEqualToString:kDeviceDesc_ModelName]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_ModelName];
    }else if ([elementName isEqualToString:kDeviceDesc_ModelNumber]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_ModelNumber];
    }else if ([elementName isEqualToString:kDeviceDesc_SerialNumber]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_SerialNumber];
    }else if ([elementName isEqualToString:kDeviceDesc_UDN]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_UDN];
    }else if ([elementName isEqualToString:kDeviceDesc_PresentationURL]){
        [deviceDescDict setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           forKey:kDeviceDesc_PresentationURL];
    }
    
    
    if ([elementName isEqualToString:@"service"]) {
        
        // add final value to dictionary
        NSString *addr;
        NSRange colonRange =  [_service.serverIPAddress rangeOfString:@":"];
        
        if (colonRange.location!=NSNotFound){
            
            addr = [_service.serverIPAddress substringWithRange:NSMakeRange(0, colonRange.location)];
        }else
            addr = _service.serverIPAddress;
        
        
        [dictTempDataStorage setObject:addr forKey:kDIALDevice_HostKey];
        
        // create our dial app object
        self.dialDevice = [[DIALDevice alloc] initWithDictionary:dictTempDataStorage];
        
        
        _status = kDIALDeviceDiscovery_DIALAppDescriptionFound;
        
        // notify main DIALServiceDiscovery component
        [_devDiscTaskdelegate DIALDeviceDiscovery:self didFindDevice:self.dialDevice];
        
    }
    else if ([elementName isEqualToString:@"name"]){
        
        [dictTempDataStorage setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                forKey:kDIALDevice_DeviceNameKey];
    }
    else if (([elementName isEqualToString:@"X_HbbTV_App2AppURL"]) || ([elementName isEqualToString:@"hbbtv:X_HbbTV_App2AppURL"])){
        [dictTempDataStorage setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                forKey:kDIALDevice_HbbTVApp2AppURLKey];
        
    }else if (([elementName isEqualToString:@"X_HbbTV_InterDevSyncURL"]) || ([elementName isEqualToString:@"hbbtv:X_HbbTV_InterDevSyncURL"])){
        
        [dictTempDataStorage setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                forKey:kDIALDevice_HbbTVInterDevSyncURKey];
    }
    else if (([elementName isEqualToString:@"X_HbbTV_UserAgent"])|| ([elementName isEqualToString:@"hbbtv:X_HbbTV_UserAgent"])){
        
        [dictTempDataStorage setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                forKey:kDIALDevice_HbbTV_UserAgentKey];
    }else if ([elementName isEqualToString:@"state"]){
        
        [dictTempDataStorage setObject:[foundElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                forKey:kDIALDevice_StateKey];
    }
    
    // Clear the mutable string.
    [foundElementValue setString:@""];
    
}

//------------------------------------------------------------------------------

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"name"] ||
        [currentElement isEqualToString:@"X_HbbTV_App2AppURL"] ||
        [currentElement isEqualToString:@"hbbtv:X_HbbTV_App2AppURL"] ||
        [currentElement isEqualToString:@"X_HbbTV_InterDevSyncURL"] ||
        [currentElement isEqualToString:@"hbbtv:X_HbbTV_InterDevSyncURL"] ||
        [currentElement isEqualToString:@"X_HbbTV_UserAgent"] ||
        [currentElement isEqualToString:@"hbbtv:X_HbbTV_UserAgent"] ||
        [currentElement isEqualToString:@"state"] ||
        [currentElement isEqualToString:@"friendlyName"] ||
        [currentElement isEqualToString:@"manufacturer"] ||
        [currentElement isEqualToString:@"modelDescription"] ||
        [currentElement isEqualToString:@"modelName"] ||
        [currentElement isEqualToString:@"modelNumber"] ||
        [currentElement isEqualToString:@"serialNumber"] ||
        [currentElement isEqualToString:@"UDN"] ||
        [currentElement isEqualToString:@"presentationURL"]
        ) {
        
        
        if (![string isEqualToString:@"\n"]) {
            [foundElementValue appendString:[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
        }
    }
}

//------------------------------------------------------------------------------

@end
