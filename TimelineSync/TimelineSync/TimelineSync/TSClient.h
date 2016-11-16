//
//  TSClient.h
//  Companion_Screen_App
//
//  Created by Rajiv Ramdhany on 09/10/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<SocketRocketiOS/SocketRocketiOS.h>
#import "ControlTimestamp.h"

@class TSClient;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------
/**
 *  TimelineSync component's state
 */
typedef NS_ENUM(NSUInteger, TSClientState) {
    /**
     *  Initialised
     */
    TSClientInitalised,
    /**
     *  Connecting to CSS-TS server
     */
    TSClientConnecting,
    /**
     *  WebSocket connection to CSS-TS server established
     */
    TSClientConnected,
    /**
     *  Setup phase completed, ready to receive Control Timestamps
     */
    TSClientTimelineSetup,
    /**
     *  Receiving Control Timestamps
     */
    TSClientRunning,
    /**
     *  Connection failure
     */
    TSClientConnectionFailure,
    /**
     *  Connection closed
     */
    TSClientConnectionClosed,
    /**
     *  Client stopped
     */
    TSClientStopped,
    /**
     *  Invalid CSS-TS server endpoint
     */
    TSClientInvalidServerURL
};



//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------

#define MSDesignatedInitializer(__SEL__) __attribute__((unavailable("Invoke the designated initializer `" # __SEL__ "` instead.")))

/**
 *  New Control Timestamp notification
 */
FOUNDATION_EXPORT NSString* const  kTSNewCRTLTimestampNotification;

/**
 *  TS Client State Notification
 */
FOUNDATION_EXPORT NSString* const  kTSClientStateChangeNotification;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - TSClientDelegate protocol
//------------------------------------------------------------------------------

/**
 *  A protocol to be implemented by a TSClient's delegate.
 */
@protocol TSClientDelegate <NSObject>

/**
 *  Callback method to report received control timestamps
 *
 *  @param ctimetamp a ControlTimestamp object (de-serialised from received JSON message)
 */
- (void) didReceiveNewControlTimetamp:(ControlTimestamp*) ctimetamp;

/**
 *  Callback method to report a broken TS protocol connection
 *
 *  @param tsEndpointURL the URL of TS protocol server endpoint to which this client is connected to
 */
- (void) tsClient:(TSClient*) ts_client StateChanged:(TSClientState) state;

//------------------------------------------------------------------------------


@end



//------------------------------------------------------------------------------
#pragma mark - TSClient Class Definition
//------------------------------------------------------------------------------

/**
 *  A DVB-CSS Timeline Synchronisation protocol client implementation. A TSClient object will
 *  connect to a DVB-CSS Timeline Synchronisation protocol server and negotiate to receive 
 *  timestamps from a selected timeline on the Timeline Synchronisation protocol server host.
 *  The protocol messages are exchanged via a WebSockets connection.
 *  The TSClient notifies other objects when new control timestamps are received in 2 ways:
 *  1) via callbacks to a TClient delegate
 *  2) via notifications kTSNewCRTLTimestampNotification
 */
@interface TSClient : NSObject <SRWebSocketDelegate>

//------------------------------------------------------------------------------
#pragma mark - properties
//------------------------------------------------------------------------------

/**
 *  TS protocol server endpoint URL
 */
@property (nonatomic, readonly) NSURL* TSServerUrl;

/**
 *  the programme (identified by contentId) for which we are receiving timeline updates
 */
@property (nonatomic, readonly) NSString* contentId;

/**
 *  the timeline whose progress we wish to receive updates. This timeline is selected by the TSClient - it specifies 
 *  a timeline selector when a TS setup message is sent. If the timeline is available at the TS server host, then progress timestamps  on that timeline are reported.
 */
@property (nonatomic, readonly) NSString* timelineSelector;

/**
 *  Is TSClient running?
 */
@property (nonatomic, readonly, getter=IsRunning) BOOL running;

/**
 *  State of TSClient
 */
@property (nonatomic, readonly) TSClientState state;


/**
 *  TSClient delegate (has to conform to TSClientDelegate protocol)
 */
@property (nonatomic) id<TSClientDelegate> delegate;

/**
 *  If true, this object will emit notifications about state change and new control timestamps
 */
@property (nonatomic) BOOL notifyObservers;




//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------



- (instancetype)init MSDesignatedInitializer(initWithEndpointURL:ContentId:TimelineSelector:);


- (id) initWithEndpointURL:(NSString*) url ContentId: (NSString*) contentid_stem TimelineSelector:(NSString*) timeline_selector;


- (id) initWithEndpointURL:(NSString*) url ContentId: (NSString*) contentid_stem TimelineSelector:(NSString*) timeline_selector Delegate:(id<TSClientDelegate>) delegate;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------
/**
 Start TS protocol client
 */
- (void) start;

//------------------------------------------------------------------------------

/**
 Stop TS protocol client
 */
- (void) stop;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Notify Observers
//------------------------------------------------------------------------------


/**
 add an observer for clock state changes. Uses Notification design pattern in Cocoa.
 */
- (void) addObserver:(id) notificationObserver selection:(SEL) notificationSelector name:(NSString *) notificationName object:(id) objectOfInterest;

//------------------------------------------------------------------------------

/**
 remove clock observer
 */
- (void) removeObserver:(id) notificationObserver;


//------------------------------------------------------------------------------


/**
 notify observers of clock state changes
 */
- (void) notifyObservers:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;

@end

//------------------------------------------------------------------------------



