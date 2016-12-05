//
//  WebViewSyncController.h
//  SyncController
//
//  Created by Rajiv Ramdhany on 20/05/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//
//  Created by Rajiv Ramdhany on 10/03/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

//  Copyright 2015 British Broadcasting Corporation
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
#import <ClockTimelines/ClockTimelines.h>
#import "SyncControllerError.h"
#import "InvocationProcessor.h"
#import "SyncControllerDelegate.h"


@class WebViewSyncController;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, WebSyncControllerState)
{
    WebSyncCrtlInitialised = 1,
    WebSyncCrtlRunning,
    WebSyncCrtlStopped,
    WebSyncCrtlPaused,
    WebSyncCrtlSynchronising,
    WebSyncCrtlSyncTimelineUnavailable,
    WebSyncCrtlSyncTimelineAvailable
};

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Timeline Synchroniser state change notification
 */
FOUNDATION_EXPORT NSString* const  kWebSyncControllerResyncNotification;


//------------------------------------------------------------------------------
#pragma mark - WebViewSyncController
//------------------------------------------------------------------------------


/**
 *  A class to send timestamps reporting progress of a TV programme to a web view.
 */
@interface WebViewSyncController : NSObject <InvocationProcessor>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  A media timeline to synchronise to.
 */
@property (nonatomic, weak) CorrelatedClock *syncTimeline;

/**
 *  The timeline of the TV programme (t=0 at start of programme). Set using correlation timestamp supplied at initialisation time.
 */
@property (nonatomic, readonly) CorrelatedClock *programmeTimeline;

/**
 *  An UIWebView this controller will send timestamps to.
 */
@property (nonatomic, weak) UIWebView *webView;

/**
 *  URL for webpage to load in webview
 */
@property (nonatomic, copy) NSURL *URL;

/**
 *  Synchronisation interval
 */
@property (nonatomic) NSTimeInterval syncInterval;

/**
 *  This sync controller's state
 */
@property (nonatomic, readonly) WebSyncControllerState state;

/**
 *  A delegate to report resynchronisation status.
 */
@property (nonatomic, weak) id<SyncControllerDelegate> delegate;

/**
 *  An HbbTV app2app URL string to pass to web view (discovered via DIAL)
 */
@property (nonatomic, copy) NSString *app2AppURL;

/**
 *  A copy of the current TV contentId
 */
@property (nonatomic, copy) NSString *contentId;



//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

- (instancetype) init NS_UNAVAILABLE;


/**
 *  Initialises an WebViewSyncController with a webview and a timeline to synchronise
 *  to.
 *
 *  @param webview      a UIWebView instance
 *  @param timeline     a CorrelatedClock instance modelling a particular timeline
 *
 *  @return initialised WebViewSyncController instance
 */
- (instancetype) initWithWebView:(UIWebView*) webview
                             URL:(NSURL*) url
                        Timeline:(CorrelatedClock*) sync_timeline
            CorrelationTimestamp:(Correlation *) correlation;

//------------------------------------------------------------------------------

/**
 *  Initialises an WebViewSyncController with a webview and a timeline to synchronise
 *  to.
 *
 *  @param webview an UIWebView instance
 *  @param timeline    a CorrelatedClock instance modelling a particular timeline
 *  @param interval_secs resynchronisation interval in seconds (as a double value)
 *
 *  @return initialised WebViewSyncController instance
 */
- (instancetype) initWithWebView:(UIWebView*) webview
                             URL:(NSURL*) url
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs;

//------------------------------------------------------------------------------

/**
 *  Initialises an WebViewSyncController with a webview and a timeline to synchronise
 *  to.
 *
 *  @param webview an UIWebView instance
 *  @param timeline    a CorrelatedClock instance modelling a particular timeline
 *  @param interval_secs resynchronisation interval in seconds (as a double value)
 *  @param delegate      a delegate object (conforming to WebViewSyncControllerDelegate protocol)
 *                       to receive callbacks
 *
 *  @return initialised WebViewSyncController instance
 */
- (instancetype) initWithWebView:(UIWebView*) webview
                             URL:(NSURL*) url
                        Timeline:(CorrelatedClock*) sync_timeline
            CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs
                            Delegate:(id<SyncControllerDelegate>) delegate;



//------------------------------------------------------------------------------
#pragma mark - Class Factory Methods
//------------------------------------------------------------------------------

/**
 *  Creates an instance of WebViewSyncController initialised with a web view and
 *  a synchronisation timelime (the timeline to synchronise to).
 *
 *  @param webview   a UIWebView object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *
 *  @return initialised WebViewSyncController instance
 */
+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation;

//------------------------------------------------------------------------------

/**
 *  Creates an instance of WebViewSyncController initialised with a web view and
 *  a synchronisation timelime (the timeline to synchronise to) and a delegate to
 *  receive callbacks.
 *
 *  @param webview   a UIWebView object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *  @param delegate      an object conforming to the WebViewSyncControllerDelegate protocol
 *
 *  @return initialised WebViewSyncController instance
 */
+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                SyncTimeline:(CorrelatedClock*) sync_timeline
                        CorrelationTimestamp:(Correlation *) correlation
                                 AndDelegate:(id<SyncControllerDelegate>) delegate ;

//------------------------------------------------------------------------------


/**
 *  Creates an instance of WebViewSyncController initialised with a web view and
 *  a synchronisation timelime (the timeline to synchronise to).  Resynchronisation of the
 *  player occurs every 'resync_interval' seconds.
 *
 *  @param webview   a UIWebView object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *  @param resync_interval resynchronisation interval in seconds
 *
 *  @return initialised WebViewSyncController instance
 */
+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                SyncTimeline:(CorrelatedClock*) sync_timeline
                        CorrelationTimestamp:(Correlation *) correlation
                             AndSyncInterval:(NSTimeInterval) resync_interval;

//------------------------------------------------------------------------------

/**
 *  Creates an instance of WebViewSyncController initialised with a web view and
 *  a synchronisation timelime (the timeline to synchronise to).  Resynchronisation of the
 *  player occurs every 'resync_interval' seconds.
 *
 *  @param webview   a UIWebView object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *  @param resync_interval resynchronisation interval in seconds
 *  @param delegate      an object conforming to the WebViewSyncControllerDelegate protocol
 *
 *  @return initialised WebViewSyncController instance
 */
+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                  SyncInterval:(NSTimeInterval) resync_interval
                                   AndDelegate:(id<SyncControllerDelegate>) delegate;



//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Start the synchronisation process.
 */
- (void) start;

//------------------------------------------------------------------------------

/**
 *  Stop the synchronisation process.
 */
- (void) stop;

//------------------------------------------------------------------------------

@end
