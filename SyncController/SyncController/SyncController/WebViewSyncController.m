//
//  WebViewSyncController.m
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

#import <SimpleLogger/MWLogging.h>
#import "WebViewSyncController.h"
#import "WebViewProxy.h"

//------------------------------------------------------------------------------
#pragma mark - Constants declaration
//------------------------------------------------------------------------------

// in seconds
NSTimeInterval const kWebReSyncIntervalDefault  = 1.0;


//------------------------------------------------------------------------------
#pragma mark - Keys and Contexts for Key Value Observation
//------------------------------------------------------------------------------

static void *WebSyncControllerContext         = &WebSyncControllerContext;
static void *WebObjectTimelineContext         = &WebObjectTimelineContext;


//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

NSString* const  kWebSyncControllerResyncNotification     =   @"WebSyncControllerResyncNotification";


//------------------------------------------------------------------------------
#pragma mark - Interface extensions
//------------------------------------------------------------------------------
@interface WebViewSyncController ()


//------------------------------------------------------------------------------
#pragma mark - access permissions redefinition, local properties
//------------------------------------------------------------------------------

@property (nonatomic, readwrite) WebSyncControllerState state;

@property (nonatomic, readwrite) WebViewProxy *proxy;

//------------------------------------------------------------------------------

@end



//------------------------------------------------------------------------------
#pragma mark - WebSyncController implementation
//------------------------------------------------------------------------------

@implementation WebViewSyncController
{
    dispatch_source_t reSyncTimer;
    NSLock *reSyncStatusLock;
}

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------


- (instancetype) initWithWebView:(UIWebView*) webview
                             URL:(NSURL*) url
                        Timeline:(CorrelatedClock*) sync_timeline
            CorrelationTimestamp:(Correlation *) correlation
{
    return [self initWithWebView:webview
                             URL:url
                        Timeline:sync_timeline
            CorrelationTimestamp:correlation
                  ReSyncInterval:kWebReSyncIntervalDefault
                        Delegate:nil];
}




//------------------------------------------------------------------------------

- (instancetype) initWithWebView:(UIWebView*) webview
                             URL:(NSURL*) url
                        Timeline:(CorrelatedClock*) sync_timeline
            CorrelationTimestamp:(Correlation *) correlation
                  ReSyncInterval:(NSTimeInterval) interval_secs
{
    return [self initWithWebView:webview
                             URL:url
                        Timeline:sync_timeline
            CorrelationTimestamp:correlation
                  ReSyncInterval:interval_secs
                        Delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype) initWithWebView:(UIWebView*) webview
                             URL:(NSURL*) url
                        Timeline:(CorrelatedClock*) sync_timeline
            CorrelationTimestamp:(Correlation *) correlation
                  ReSyncInterval:(NSTimeInterval) interval_secs
                        Delegate:(id<SyncControllerDelegate>) delegate
{
    
    self = [super init];
    
    if (self != nil) {
        
        _webView = webview;
        _URL = url;
        _syncTimeline = sync_timeline;
        _syncInterval = interval_secs;
        _delegate = delegate;
        
        
        // create the expected media object timeline
        _programmeTimeline = [[CorrelatedClock alloc] initWithParentClock:_syncTimeline
                                                                   TickRate:_kOneThousandMillion
                                                                Correlation:correlation];
        
        // register this controller to listen to changes to this clock (availability,
        [_programmeTimeline addObserver:self context:WebObjectTimelineContext ];
        
        _programmeTimeline.available = _syncTimeline.available;
        
        
        reSyncStatusLock = [[NSLock alloc] init];
        
        reSyncTimer = nil;
        
        _proxy = [[WebViewProxy alloc] initWithWebView:webview withInvocationHandler:self];
        
        _state = WebSyncCrtlInitialised;

        
        if (_programmeTimeline.available) [self start];
        
    }
    return self;
}




//------------------------------------------------------------------------------
#pragma mark - Class Factory Methods
//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                SyncTimeline:(CorrelatedClock*) sync_timeline
                        CorrelationTimestamp:(Correlation *) correlation
{
    return [[WebViewSyncController alloc] initWithWebView:webview
                                                      URL:url
                                                 Timeline:sync_timeline
                                     CorrelationTimestamp:correlation
                                           ReSyncInterval:kWebReSyncIntervalDefault
                                                 Delegate:nil];
}

//------------------------------------------------------------------------------


+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                SyncTimeline:(CorrelatedClock*) sync_timeline
                        CorrelationTimestamp:(Correlation *) correlation
                                 AndDelegate:(id<SyncControllerDelegate>) delegate
{
    return [[WebViewSyncController alloc] initWithWebView:webview
                                                      URL:url
                                                 Timeline:sync_timeline
                                     CorrelationTimestamp:correlation
                                           ReSyncInterval:kWebReSyncIntervalDefault
                                                 Delegate:delegate];
}

//------------------------------------------------------------------------------


+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                SyncTimeline:(CorrelatedClock*) sync_timeline
                        CorrelationTimestamp:(Correlation *) correlation
                             AndSyncInterval:(NSTimeInterval) resync_interval
{
    
    return [[WebViewSyncController alloc] initWithWebView:webview
                                                      URL:url
                                                 Timeline:sync_timeline
                                     CorrelationTimestamp:correlation
                                           ReSyncInterval:resync_interval
                                                 Delegate:nil];
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithUIWebView:(UIWebView*) webview
                                         URL:(NSURL*) url
                                SyncTimeline:(CorrelatedClock*) sync_timeline
                        CorrelationTimestamp:(Correlation *) correlation
                                SyncInterval:(NSTimeInterval) resync_interval
                                 AndDelegate:(id<SyncControllerDelegate>) delegate
{
    
    return [[WebViewSyncController alloc] initWithWebView:webview
                                                      URL:url
                                                 Timeline:sync_timeline
                                     CorrelationTimestamp:correlation
                                           ReSyncInterval:resync_interval
                                                 Delegate:delegate];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - setters
//------------------------------------------------------------------------------

- (void) setState:(WebSyncControllerState)state
{
    
    _state = state;
    
    __weak WebViewSyncController *weakSelf = self;
    
    // dispatch callbacks and notifications asynchronously
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_delegate) {
            [_delegate SyncController:self DidChangeState:state];
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSyncControllerResyncNotification object:weakSelf userInfo:@{kWebSyncControllerResyncNotification: [NSNumber numberWithUnsignedInteger: _state]}];
        
    });
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------


- (void) start
{
    // run
    [_proxy loadUrl:self.URL.absoluteString];
    
    //[_proxy loadPage:@"index.html"fromFolder:@"www"];
    
    if (!reSyncTimer) {
        reSyncTimer = ___CreateDispatchTimer___(_syncInterval * NSEC_PER_SEC,
                                              1* NSEC_PER_MSEC,
                                              dispatch_get_main_queue(),
                                              ^{ [self ReSync]; });        dispatch_resume(reSyncTimer);
        MWLogDebug(@"WebViewSyncController(): reSync timer started.");
    }else
    {
        if (self.state == WebSyncCrtlPaused)
            dispatch_resume(reSyncTimer);
    }
    
    // send current content id to web view
    
    self.state = WebSyncCrtlRunning;
}

//------------------------------------------------------------------------------


- (void) stop
{
    [self ___cancelTimer___:reSyncTimer];
    
    
    
    // unregister the media Object Timeline clock as an observer of the synctimeline clock
    [_programmeTimeline removeObserver:self Context:WebObjectTimelineContext];
    
    
    self.state = WebSyncCrtlStopped;
    
    
    [self.webView stopLoading];
    
    self.webView.delegate = nil;
    self.webView = nil;
    self.proxy.webView = nil;
    
    
    _programmeTimeline = nil;
     _proxy = nil;
   
}

//------------------------------------------------------------------------------

- (void)dealloc
{
   
    _syncTimeline = nil;
    
    MWLogDebug(@"WebViewSyncController deallocated.");
    
}

//------------------------------------------------------------------------------

- (void)suspend
{
    if (reSyncTimer) {
        dispatch_suspend(reSyncTimer);
        
    }
    
    self.state = WebSyncCrtlPaused;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - KVO for WallClock and TVTimeline
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == WebObjectTimelineContext) {
        
        
        if ([keyPath isEqualToString:kTickRateKey]) {
            
            
        }else if ([keyPath isEqualToString:kSpeedKey]) {
            
            NSLog(@"WebViewSyncController: media object timeline speed changed.");
            
            // set the speed
            //            float oldSpeed = [[change objectForKey:@"old"] floatValue];
            //            float newSpeed = [[change objectForKey:@"new"] floatValue];
            
            // trigger a resync with speed == 0.0
            
            if (self.state == WebSyncCrtlRunning) [self ReSync];
            
        }else if([keyPath isEqualToString:kCorrelationKey]) {
            NSLog(@"WebViewSyncController: media object timeline correlation changed.");
            
            // trigger a resync
            if (self.state == WebSyncCrtlRunning) [self ReSync];
            
          
        }else if ([keyPath isEqualToString:kAvailableKey]) {
            
            BOOL oldAvailable = [[change objectForKey:@"old"]boolValue];
            BOOL newAvailable = [[change objectForKey:@"new"]boolValue];
            
            NSString *msg = [NSString stringWithFormat:@"changed from %d to %d", oldAvailable, newAvailable];
            
            NSLog(@"WebViewSyncController: media object timeline availability  %@", msg);
            
            // if available == true AND VideoPlayerSyncController is not sync'ing, start resync
            
            if ((newAvailable) && ((_state == WebSyncCrtlInitialised) || (_state == WebSyncCrtlSyncTimelineUnavailable)))
            {
                self.state = WebSyncCrtlSyncTimelineAvailable;
                
                [self start];
            }else if ((!newAvailable) && ((_state == WebSyncCrtlRunning) || (_state == WebSyncCrtlSynchronising)))
            {
                [self suspend];
            }
        }
    }
    
}


//------------------------------------------------------------------------------
#pragma mark - Private methods
//------------------------------------------------------------------------------

/**
 *  Sends programme timeline position to webview. This method is called
 *  every syncInterval seconds or after an observed change in the time correlation
 *
 */
- (void) ReSync
{
    // resync method will be called these threads:
    // 1) by resync timer thread
    // 2) by thread reporting KVO changes on the TV timeline correlation/speed
    
    
    // thread safety ensured by serialising access to resync code
    
    //    if ([reSyncStatusLock tryLock]){
    
    if (self.state != WebSyncCrtlSynchronising){
        
        self.state = WebSyncCrtlSynchronising;
        
        
        NSTimeInterval programmeTimeNowSecs    = [self.programmeTimeline time];
        
        NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
        
        [paramsDict setObject:[NSNumber numberWithDouble:programmeTimeNowSecs]
                       forKey:@"contentTime"];
        [paramsDict setObject:[NSNumber numberWithFloat:self.programmeTimeline.speed]
                       forKey:@"timespeedMultiplier"];
        
//        MWLogDebug(@"WebViewSyncController:  ContentTime: %@", [paramsDict objectForKey:@"contentTime"]);
//        MWLogDebug(@"WebViewSyncController: timespeedMultiplier: %@", [paramsDict objectForKey:@"timespeedMultiplier"]);
        
        [_proxy callJSFunction:@"updateTimeline" withArgs:paramsDict];
        
       
    } // end if (self.state != AudioSyncCrtlSynchronising)
    
    //        // release the lock
    //        [reSyncStatusLock unlock];
    //    }
    
    self.state = WebSyncCrtlRunning;
    
}


/**
 *  Create a timer using a dispatch source (See Grand Central Dispatch reference)
 *
 *  @param interval time intervak in seconds
 *  @param leeway   a leeway in seconds
 *  @param queue    dispatch queue for the task
 *  @param block    task to be executed
 *
 *  @return a timer of type dispatch_source_t
 */
dispatch_source_t ___CreateDispatchTimer___(uint64_t interval,
                                          uint64_t leeway,
                                          dispatch_queue_t queue,
                                          dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        
    }
    return timer;
}

//------------------------------------------------------------------------------

- (void) ___cancelTimer___:(dispatch_source_t) timer
{
    if (timer) {
        dispatch_source_cancel(timer);
        // Remove this if you are on a Deployment Target of iOS6 or OSX 10.8 and above
        timer = nil;
    }
}



//------------------------------------------------------------------------------
#pragma mark - InvocationProcessor protocol methods
//------------------------------------------------------------------------------

- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error
{
    if ([name compare:@"registerForTimelineUpdates" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        MWLogDebug(@"WebViewSyncController: method registerForTimelineUpdates invoked from JS %@ %@", args[0], args[1]);
        if ((_state != WebSyncCrtlRunning) && (_state !=WebSyncCrtlSynchronising))
        {
            [self start];
            MWLogDebug(@"WebViewSyncController: synccontroller started for webview");
        }
      
    }
    
    else if ([name compare:@"stopSyncController" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        
        [self stop];
        
        
    }else if ([name compare:@"reloadPage" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
       [self.proxy loadUrl:self.URL.absoluteString ];
    }
    
    else if ([name compare:@"getApp2AppURL" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
       
        if (self.app2AppURL) {

            return [NSString stringWithFormat:@"%@remoteApp", self.app2AppURL];
        }
    }
    else if ([name compare:@"getContentId" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        
        if (self.contentId) {
            
            return [NSString stringWithFormat:@"%@", self.contentId];
        }else
            return [NSString stringWithFormat:@"NULL"];
    }
    
    
    
    return @"success";
    
}

@end



