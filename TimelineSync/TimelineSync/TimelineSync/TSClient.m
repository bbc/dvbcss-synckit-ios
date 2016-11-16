//
//  TSClient.m
//  Companion_Screen_App
//
//  Created by Rajiv Ramdhany on 09/10/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//


#import <SyncKitConfiguration/SyncKitConfiguration.h>

#import <SimpleLogger/MWLogging.h>
#import <SyncKitCollections/utils.h>
#import "TSClient.h"
#import "TSSetupMsg.h"



//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------

NSString* const  kTSNewCRTLTimestampNotification    = @"TSNewCRTLTimestampNotification";
NSString * const kTSClientStateChangeNotification   = @"TSClientStateChangeNotification";



//------------------------------------------------------------------------------
#pragma mark - TSClient Interface extensions
//------------------------------------------------------------------------------

@interface TSClient ()

//------------------------------------------------------------------------------
#pragma mark - access permissions redefinition
//------------------------------------------------------------------------------
@property (nonatomic, readwrite) NSURL* TSServerUrl;
@property (nonatomic, readwrite) NSString* contentId;
@property (nonatomic, readwrite) NSString* timelineSelector;
@property (nonatomic, readwrite) BOOL running;
@property (nonatomic, readwrite) TSClientState state;

//------------------------------------------------------------------------------
/**
 *  Reference to global configuration settings object (a singleton)
 */
@property (nonatomic, weak) SyncKitGlobals* globalConstants;


//------------------------------------------------------------------------------
#pragma mark - private methods
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
/**
 *  connect this TSClient's WebSocket
 */
- (void)connectWebSocket;

//------------------------------------------------------------------------------

@end



//------------------------------------------------------------------------------
#pragma mark - TSClient implementation
//------------------------------------------------------------------------------

@implementation TSClient
{
    SRWebSocket *webSocket;
    BOOL socket_open;
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle methods: Initialization, Dealloc, etc
//------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        // get a reference to object containing device constants
        self.globalConstants = [SyncKitGlobals getInstance];
        
        assert(_globalConstants!=nil);
        _TSServerUrl = [NSURL URLWithString: _globalConstants.tsURL];
        _contentId = @"dvb://233A.1004.1044";
        _timelineSelector = @"urn:dvb:css:timeline:pts";
        _state = TSClientInitalised;
        _delegate = nil;
        _notifyObservers = YES;
        
    }
    
    return self;
}

//------------------------------------------------------------------------------

- (id) initWithEndpointURL:(NSString*) url ContentId: (NSString*) contentid_stem TimelineSelector:(NSString*) timeline_selector
{
    self = [super init];
    
    
    if (self != nil) {
        
        
        self.globalConstants = [SyncKitGlobals getInstance];
        assert(_globalConstants!=nil);
        
        _TSServerUrl = [NSURL URLWithString:url];
        _contentId = contentid_stem;
        _timelineSelector = timeline_selector;
        _state = TSClientInitalised;
        _delegate = nil;
        _notifyObservers = YES;

    }
    return self;
}
//------------------------------------------------------------------------------


- (id) initWithEndpointURL:(NSString*) url ContentId: (NSString*) contentid_stem TimelineSelector:(NSString*) timeline_selector Delegate:(id<TSClientDelegate>) delegate;
{
    self = [super init];

    if (self != nil) {
        self.globalConstants = [SyncKitGlobals getInstance];
        assert(_globalConstants!=nil);
        
        _TSServerUrl = [NSURL URLWithString:url];
        
        assert(_TSServerUrl!=nil);
        
        _contentId = contentid_stem;
        _timelineSelector = timeline_selector;
        _state = TSClientInitalised;
        _notifyObservers = YES;
        _delegate = delegate;
        
    }
    return self;
}

//------------------------------------------------------------------------------

- (void)dealloc
{
    if (socket_open)
        [webSocket close];
    webSocket = nil;
    _TSServerUrl = nil;
    
    NSLog(@"TSClient deallocated.");
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

/**
 *  When state property is set, dispatch notifications and callbacks
 *
 *  @param state a TSClientState
 */
- (void) setState:(TSClientState)state
{
    
    _state = state;
    
    __weak TSClient *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_delegate) {
            [_delegate tsClient:weakSelf StateChanged:_state];
        }
        
        if (weakSelf.notifyObservers) {
            [weakSelf notifyObservers:kTSClientStateChangeNotification
                           object:weakSelf
                         userInfo:@{kTSClientStateChangeNotification: [NSNumber numberWithUnsignedInteger: _state]}];
        }
    });
    
}



//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (BOOL) IsRunning
{
    if ((_state == TSClientRunning) || (_state == TSClientConnected)|| (_state == TSClientTimelineSetup)) {
        return YES;
    }else
        return NO;
}


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void) start
{
    
    self.state = TSClientConnecting;
    
    [self connectWebSocket];
    
    socket_open = YES;
}

//------------------------------------------------------------------------------

- (void) stop
{
    self.state = TSClientStopped;
    
    
    if (socket_open){
        [webSocket close];
         webSocket = nil;
    }
}
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - private methods
//------------------------------------------------------------------------------

- (void)connectWebSocket {
    
    if (webSocket != nil) {
        [webSocket close];
        webSocket.delegate = nil;
        webSocket = nil;
    }
    
    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:_TSServerUrl];
    newWebSocket.delegate = self;
    
    [newWebSocket open];
}


//------------------------------------------------------------------------------
#pragma mark - SRWebSocket delegate methods
//------------------------------------------------------------------------------

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    webSocket = newWebSocket;
    MWLogDebug(@"TimelineSyncClient: web socket opened to url: %@", _TSServerUrl);
    
    self.state = TSClientConnected;
    
    // send Timeline Synchronisation set up message (see DVB Spec clause 5.7.3)
    TSSetupMsg* msg = [[TSSetupMsg alloc] init:self.contentId TimelineSel:self.timelineSelector];
    
    NSString* setupmsg= [msg toJSONString];
    
    MWLogDebug(@"TimelineSyncClient: sent timeline request %@", setupmsg);
    
    [webSocket send:setupmsg];

     self.state = TSClientTimelineSetup;
}

//------------------------------------------------------------------------------

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    self.state = TSClientConnectionFailure;
    
    MWLogDebug(@"TimelineSyncClient: received error: %@", DisplayErrorFromError(error));
    
    
}

//------------------------------------------------------------------------------

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    MWLogDebug(@"TimelineSyncClient: web socket to %@ closed. reason: %@", self.TSServerUrl, reason);
    socket_open = false;
    
    self.state = TSClientConnectionClosed;
}

//------------------------------------------------------------------------------

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    self.state = TSClientRunning;
    
    if ([message isKindOfClass:[NSString class]])
    {
        //parse our JSON string
      
        MWLogDebug(@"TimelineSyncClient: received string: %@", message);
        // MWLogDebug(@"TimelineSyncClient: received control timestamp");
        NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        ControlTimestamp* timelineUpdate = [ControlTimestamp ControlTimestampWithDictionary:jsonDict];
        
       // uint64_t tv_contentTimePTSTicks = strtoull([ctime.contentTime UTF8String], NULL, 0);
        //uint64_t tv_wallclockTimeNanos = strtoull([ctime.wallClockTime UTF8String], NULL, 0);
        
        if (self.running){
        
            if (_delegate)
            {
                [self.delegate didReceiveNewControlTimetamp:timelineUpdate];
            }
            
            if (self.notifyObservers){
                [self notifyObservers:kTSNewCRTLTimestampNotification object:self userInfo:@{kTSNewCRTLTimestampNotification: timelineUpdate}];
            }
        }
    }else{
        
        MWLogError(@"TimelineSyncClient: Error,  binary msg received from TS server");
    }
}
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - Notify Observers methods
//------------------------------------------------------------------------------

/*
 * add an observer for clock state changes
 */
- (void) addObserver:(id) notificationObserver selection:(SEL) notificationSelector name:(NSString *) notificationName object:(id) objectOfInterest

{
    [[NSNotificationCenter defaultCenter] addObserver:notificationObserver selector:notificationSelector name:notificationName object:objectOfInterest];
}

//------------------------------------------------------------------------------


/**
 * remove  observer.
 */
- (void) removeObserver:(id) notificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

//------------------------------------------------------------------------------

/**
 * Notify all observers about the Timeline Synchronisation updates
 */
- (void) notifyObservers:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:notificationSender userInfo:userInfo];
}


//------------------------------------------------------------------------------


@end
