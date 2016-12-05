//
//  CII.m
//  Companion_Screen_App
//
//  Created by Rajiv Ramdhany on 09/10/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import "CIIClient.h"
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SimpleLogger/SimpleLogger.h>
#import <SyncKitCollections/SyncKitCollections.h>


NSString * const kCIIConnectionFailure          = @"CIIConnectionFailure";
NSString * const kCIIDidChange                  = @"CIIDidChange";
NSString * const kCIIChangeStatusMask           = @"CIICIIChangeStatusMask";



@interface CIIClient()
{
    
}
@property (nonatomic, weak) SyncKitGlobals* devinfo;
@property (nonatomic, readwrite) CII* ciiInstance;

- (void)connectWebSocket;

@end



@implementation CIIClient
{
    SRWebSocket *webSocket;
}
@synthesize devinfo = _devinfo;



#pragma mark init methods
- (id)init
{
    self = [super init];
    if (self != nil) {
        
        // get a reference to object containing device constants
        _devinfo = [SyncKitGlobals getInstance];
        
        assert(_devinfo!=nil);
        _ciiUrl = _devinfo.ciiURL;
        
        _ciiInstance = nil;
    }

    return self;
}

/**
 Initialise the measurement collector
 */
- (id) initWithCIIURL:(NSString*) cii_url
{
    self = [super init];
    
    
    if (self != nil) {
        
        // get ConfigReader singleton
        // get a reference to object containing device constants
        _devinfo = [SyncKitGlobals getInstance];
        _ciiUrl = cii_url;
        
        
    }
    return self;
    
}


- (void)dealloc
{
    [self stop];
    webSocket = nil;
    
    
}


/**
 Start CII client;
 */
- (void) start
{
    [self connectWebSocket];
}

/**
 pause the component. To restart, call start method
 */
- (void) pause
{
    [webSocket close];
}

- (void) stop
{
    [webSocket close];
    webSocket = nil;
}


#pragma mark - SRWebSocket delegate

- (void)connectWebSocket {
    
    if (webSocket != nil) {
        [webSocket close];
        webSocket.delegate = nil;
        webSocket = nil;
    }
    
    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_ciiUrl]];
    newWebSocket.delegate = self;
    
    [newWebSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    webSocket = newWebSocket;
    MWLogDebug(@"CIIClient: web socket opened to url: %@", _ciiUrl);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    MWLogDebug(@"CIIClient: received error: %@", DisplayErrorFromError(error));
    
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    MWLogDebug(@"CIIClient:  web socket to %@ closed. reason: %@", _ciiUrl, reason);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject: [_ciiUrl copy] forKey:kCIIConnectionFailure];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCIIConnectionFailure object:nil userInfo:dictionary];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    CIIChangeStatus ciiClientStatus = 0;
    
    if ([message isKindOfClass:[NSString class]])
    {
        //parse our JSON string
        MWLogDebug(@"CIIClient: received a cii message: %@", message);
//        MWLogDebug(@"CIIClient: received a cii message.");
        
         NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        
        CII* anotherCiiInstance = [[CII alloc] initWithJSONString:message];
        
        if (!self.ciiInstance) {
            ciiClientStatus |= NewCIIReceived;
            self.ciiInstance = anotherCiiInstance;
            
        }else
        {
            if (anotherCiiInstance)
            {
                // check if field was included in message
                
                if (anotherCiiInstance.msrUrl) {
                 
                    if (self.ciiInstance.msrUrl == nil)
                    {
                        self.ciiInstance.msrUrl = anotherCiiInstance.msrUrl;
                        ciiClientStatus |= MRSUrlChanged;
                        
                    }else if([self hasStringFieldValueChanged:self.ciiInstance.msrUrl New:anotherCiiInstance.msrUrl])
                    {
                        self.ciiInstance.msrUrl = anotherCiiInstance.msrUrl;
                        ciiClientStatus |= MRSUrlChanged;
                    }
                } // end if (anotherCiiInstance.msrUrl)
                
                // content Id
                if (anotherCiiInstance.contentId) {
                    
                    if (self.ciiInstance.contentId == nil)
                    {
                        self.ciiInstance.contentId = anotherCiiInstance.contentId;
                        ciiClientStatus |= ContentIdChanged;
                        
                    }else if([self hasStringFieldValueChanged:self.ciiInstance.contentId New:anotherCiiInstance.contentId])
                    {
                        self.ciiInstance.contentId = anotherCiiInstance.contentId;
                        ciiClientStatus |= ContentIdChanged;
                    }
                } // end if (anotherCiiInstance.contentId)

                
                // contentIdStatus
                if (anotherCiiInstance.contentIdStatus) {
                    
                    if (self.ciiInstance.contentIdStatus == nil)
                    {
                        self.ciiInstance.contentIdStatus = anotherCiiInstance.contentIdStatus;
                        ciiClientStatus |= ContentIdStatusChanged;
                        
                    }else if([self hasStringFieldValueChanged:self.ciiInstance.contentIdStatus New:anotherCiiInstance.contentIdStatus])
                    {
                        self.ciiInstance.contentIdStatus = anotherCiiInstance.contentIdStatus;
                        ciiClientStatus |= ContentIdStatusChanged;
                    }
                } // end if (anotherCiiInstance.contentIdStatus)
                
                               
                // presentationStatus
                if (anotherCiiInstance.presentationStatus) {
                    if (self.ciiInstance.presentationStatus == nil)
                    {
                        self.ciiInstance.presentationStatus = anotherCiiInstance.presentationStatus;
                        ciiClientStatus |= PresentationStatusChanged;
                        
                    }else if([self hasStringFieldValueChanged:self.ciiInstance.presentationStatus New:anotherCiiInstance.presentationStatus])
                    {
                        self.ciiInstance.presentationStatus = anotherCiiInstance.presentationStatus;
                        ciiClientStatus |= PresentationStatusChanged;
                    }
                } // end if (anotherCiiInstance.presentationStatus)
                
                // wcUrl
                if (anotherCiiInstance.wcUrl) {
                    if (self.ciiInstance.wcUrl == nil)
                    {
                        self.ciiInstance.wcUrl = anotherCiiInstance.wcUrl;
                        ciiClientStatus |= WCSUrlChanged;
                        
                    }else if([self hasStringFieldValueChanged:self.ciiInstance.wcUrl New:anotherCiiInstance.wcUrl])
                    {
                        self.ciiInstance.wcUrl = anotherCiiInstance.wcUrl;
                        ciiClientStatus |= WCSUrlChanged;
                    }
                } // end if (anotherCiiInstance.wcUrl)
                
                
                // tsUrl
                if (anotherCiiInstance.tsUrl) {
                    if (self.ciiInstance.tsUrl == nil)
                    {
                        self.ciiInstance.tsUrl = anotherCiiInstance.tsUrl;
                        ciiClientStatus |= TSSUrlChanged;
                        
                    }else if([self hasStringFieldValueChanged:self.ciiInstance.tsUrl New:anotherCiiInstance.tsUrl])
                    {
                        self.ciiInstance.tsUrl = anotherCiiInstance.tsUrl;
                        ciiClientStatus |= TSSUrlChanged;
                    }
                } // end if (anotherCiiInstance.tsUrl)
                
                
                // timelines
                if (anotherCiiInstance.timelines){
                    if (![self.ciiInstance.timelines isEqualToArray:anotherCiiInstance.timelines]){
                        
                        ciiClientStatus |= TimelinesChanged | TimelineSelectorChanged;
                        [self.ciiInstance.timelines removeAllObjects];
                        self.ciiInstance.timelines = nil;
                        self.ciiInstance.timelines = anotherCiiInstance.timelines;
                    }
                }
                
            }
        }
        
        if (ciiClientStatus!=0){
            // inform listeners about new CII information
            [dictionary setObject:self.ciiInstance forKey:kCIIDidChange];
            [dictionary setObject:[NSNumber numberWithUnsignedInteger:ciiClientStatus] forKey:kCIIChangeStatusMask];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCIIDidChange object:nil userInfo:dictionary];
        }
        
        
    }else{
        
        MWLogError(@"Error, CIIProtoImpl - didReceiveMessage(): binary received from CII server");
    }
}


- (BOOL) hasStringFieldValueChanged:(NSString*) origStr
                                New:(NSString*) newStr
{
    NSNull *nullObject = [NSNull null];
    
    // check if both mrsURL fields are not NSNull
    if (origStr!=newStr)
    {
        if ((origStr == nullObject) ||
            (newStr == nullObject))
        {
           // one of them is NSNULL
            return true;
        }
        
        if ((origStr != nullObject) &&
            (newStr != nullObject))
        {
            if ([origStr caseInsensitiveCompare:newStr] !=NSOrderedSame){
                return true;
            }
        }
    }
    // else ciiInstance.msrUrl and anotherCiiInstance.msrUrl both point to NSNull singleton object.
    
    
    return NO;
    
}


#pragma mark notify methods

/*
 * add an observer for clock state changes
 */
- (void) addObserver:(id) notificationObserver selection:(SEL) notificationSelector name:(NSString *) notificationName object:(id) objectOfInterest

{
    [[NSNotificationCenter defaultCenter] addObserver:notificationObserver selector:notificationSelector name:notificationName object:objectOfInterest];
}

/**
 * remove  oberver.
 */
- (void) removeObserver:(id) notificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

/**
 * Notify all observers about the clock state changes
 */
- (void) notifyObservers:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo
{
    
    
    NSNotification *myNotification =
    [NSNotification notificationWithName:notificationName object:notificationSender userInfo:userInfo];
    
    
    [[NSNotificationQueue defaultQueue]  enqueueNotification:myNotification
                                                postingStyle:NSPostNow
                                                coalesceMask:NSNotificationNoCoalescing
                                                    forModes:nil];
}
@end
