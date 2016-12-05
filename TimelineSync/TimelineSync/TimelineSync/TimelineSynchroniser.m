//
//  TimelineSynchroniser.m
//  TimelineSync
//
//  Created by Rajiv Ramdhany on 18/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//

#import <SimpleLogger/MWLogging.h>
#import "TimelineSynchroniser.h"
#import "TSClient.h"


//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------


NSString * const kTSStateChangeNotification   = @"TSStateChangeNotification";


//------------------------------------------------------------------------------
#pragma mark - TimelineSynchroniser (Interface Extension)
//------------------------------------------------------------------------------
@interface TimelineSynchroniser() <TSClientDelegate>
{
    
}

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  Accessor permission redefinition
 */
@property (nonatomic, readwrite) CorrelatedClock *cssTVTimeline;
@property (nonatomic, readwrite) NSString *timelineSelector;
@property (nonatomic, readwrite) NSString *contentId;
@property (nonatomic, readwrite) BOOL isSynced;
@property (nonatomic, readwrite) NSString *tsEndpointURL;
@property (nonatomic, readwrite) TSState state;

//------------------------------------------------------------------------------
/**
 *  A CSS-TS protocol client object
 */
@property (nonatomic) TSClient* tsclient;

//------------------------------------------------------------------------------

@end



//------------------------------------------------------------------------------
#pragma mark - TimelineSynchroniser implementation
//------------------------------------------------------------------------------

@implementation TimelineSynchroniser
{
    NSLock *lock;
}


//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------


+ (instancetype) TimelineSynchroniserWithTimeline:(CorrelatedClock*) timeline
                                 TimelineSelector:(NSString*) timelineSel
                                          Content:(NSString*) content_id
                                              URL:(NSString*) ts_endpoint
{
    return [TimelineSynchroniser TimelineSynchroniserWithTimeline:timeline
                                                 TimelineSelector:timelineSel
                                                          Content:content_id
                                                              URL:ts_endpoint
                                                           Offset:0];
}


//------------------------------------------------------------------------------

+ (instancetype) TimelineSynchroniserWithTimeline:(CorrelatedClock*) timeline
                                 TimelineSelector:(NSString*) timelineSel
                                          Content:(NSString*) content_id
                                              URL:(NSString*) ts_endpoint
                                           Offset:(NSTimeInterval)offset_ms
{
    
    TimelineSynchroniser* newTimelineSyncer = [[self alloc] init];
    
    newTimelineSyncer.cssTVTimeline = timeline;
    newTimelineSyncer.cssTVTimeline.available = NO;
    newTimelineSyncer.timelineSelector = timelineSel;
    newTimelineSyncer.contentId = content_id;
    newTimelineSyncer.isSynced = NO;
    newTimelineSyncer.tsEndpointURL = ts_endpoint;
    newTimelineSyncer.offset = offset_ms;
    
       
    NSRange semiColonRange =  [content_id rangeOfString:@"?"];
    
    if (semiColonRange.location!=NSNotFound){
        
         newTimelineSyncer.contentId = [content_id substringWithRange:NSMakeRange(0, semiColonRange.location)];
    }else
         newTimelineSyncer.contentId = content_id;
    

    
    newTimelineSyncer.tsclient = [[TSClient alloc] initWithEndpointURL:newTimelineSyncer.tsEndpointURL
                                                             ContentId:newTimelineSyncer.contentId
                                                      TimelineSelector:newTimelineSyncer.timelineSelector                                                     ];
    
    MWLogDebug(@"TSClient object created");
    
    newTimelineSyncer.state = TSInitalised;
    
    
    
    return newTimelineSyncer;
    
}


//------------------------------------------------------------------------------
#pragma mark - setters
//------------------------------------------------------------------------------

- (void) setState:(TSState)state
{
    
    _state = state;
    
    __weak TimelineSynchroniser *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_delegate) {
            [_delegate ts:weakSelf DidChangeState:state];
        }
        
        if (weakSelf.notifyObservers) {
            [weakSelf notifyObservers:kTSStateChangeNotification
                               object:weakSelf
                             userInfo:@{kTSStateChangeNotification: [NSNumber numberWithUnsignedInteger: _state]}];
        }
    });
}


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void) start
{
    if (!_tsclient) {
        _tsclient = [[TSClient alloc] initWithEndpointURL:_tsEndpointURL
                                                ContentId:_contentId
                                         TimelineSelector:_timelineSelector];
        
    }
    self.tsclient.delegate = self;
    lock = [[NSLock alloc] init];
    
    [self.tsclient start];
    
    MWLogDebug(@" TimelineSynchroniser, synchronising TV timeline %@ ", _timelineSelector);
}

//------------------------------------------------------------------------------

- (void) stop
{
    [self.tsclient stop];
    self.cssTVTimeline.available = NO;
    self.state = TSClientStopped;
    self.tsclient = nil;
    
    MWLogDebug(@"TimelineSynchroniser stopped.");
    
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - TSClientDelegate methods
//------------------------------------------------------------------------------

/**
 *  This thread-safe callback method gets called when a Control Timestamp is received in the TSClient via WebSockets.
 *  The WebSockets library may use a different thread/dispatcher for the message handler callback. 
 *  didReceiveNewControlTimetamp method is thread-safe.
 *
 *  @param ctimestamp a Control Timestamp
 */
- (void) didReceiveNewControlTimetamp:(ControlTimestamp*) ctimestamp
{
     //MWLogDebug(@"TimeSynchroniser: received control timestamp {%@,%@, %f}", ctimestamp.wallClockTime ,ctimestamp.contentTime, ctimestamp.timelineSpeedMultiplier );
    
    // check if any timestamps are NULL
    
    if ((ctimestamp.contentTime == nil) || (ctimestamp.contentTime == NULL))
    {
        // the timeline is unavailable, set cssTVTimeline.available property and update state
        self.cssTVTimeline.available = NO;
        self.state = TSTimelineUnavailable;
    }else{
    
        int64_t tv_contentTimePTSTicks = strtoll([ctimestamp.contentTime UTF8String], NULL, 0);
        int64_t tv_wallclockTimeNanos = strtoll([ctimestamp.wallClockTime UTF8String], NULL, 0);
        
        tv_wallclockTimeNanos += (self.offset * 1000000);
        
            
        if ([lock tryLock]){
            // --- update the cssTVTimeline with the received correlation ---
            
            // convert WallClock timestamp to ticks and create a Correlation object
            ClockBase* wallclock = self.cssTVTimeline.parent;
            
            Correlation corel;
            corel.parentTickValue = [wallclock nanoSecondsToTicks:tv_wallclockTimeNanos];
            corel.tickValue = tv_contentTimePTSTicks;
            
            
            // set new correlation after checking that it is different (TV sometimes sends the same correlation timestamp more than once)
            
            if (self.cssTVTimeline.correlation.parentTickValue!=corel.parentTickValue){
                
                MWLogDebug(@"TimeSynchroniser: updating cssTVTimeline with correlation {%lld,%lld, %f}.", corel.parentTickValue, corel.tickValue, ctimestamp.timelineSpeedMultiplier);
                
                self.cssTVTimeline.correlation = corel;
                if (self.cssTVTimeline.speed != ctimestamp.timelineSpeedMultiplier) {
                    self.cssTVTimeline.speed = ctimestamp.timelineSpeedMultiplier;
                }
                
                if(!self.cssTVTimeline.available)
                    self.cssTVTimeline.available= YES;
             }
            
            [lock unlock];
            
        }
        self.state = TSSynced;
        
    }
}

//------------------------------------------------------------------------------

- (void) tsClient:(TSClient*) ts_client StateChanged:(TSClientState) tsclient_state
{
   // MWLogDebug(@"tsclient state: %u", tsclient_state);
    
    if (tsclient_state == TSClientConnected)
        self.state= TSConnected;
    else if (tsclient_state == TSClientTimelineSetup)
        self.state= TSTimelineSetup;
    else if (tsclient_state == TSClientRunning)
        self.state = TSSynced;
    else if (tsclient_state == TSClientConnectionFailure)
        self.state = TSConnectionFailure;
    else if ((tsclient_state == TSClientConnectionClosed) || (tsclient_state == TSClientStopped))
        self.state = TSStopped;
    
}

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
