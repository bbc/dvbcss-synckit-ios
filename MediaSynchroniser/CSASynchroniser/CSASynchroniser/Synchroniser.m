//  Synchroniser.m
//  Synchroniser
//
//  Created by Rajiv Ramdhany on 23/05/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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


#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SimpleLogger/MWLogging.h>

#import "Synchroniser.h"

//------------------------------------------------------------------------------
#pragma mark - Constants declaration
//------------------------------------------------------------------------------

/**
 *  Resynchronisation interval
 */
NSTimeInterval const kDefaultResyncInterval         = 4.0;      // seconds

/**
 *  Video callibration offset
 */
NSTimeInterval const kVideoCallibrationOffset       = -19.333;  // milliseconds

/**
 *  AV media audio track callibration offset
 */
NSTimeInterval const kVideoSoundCallibrationOffset  = 64;       // milliseconds

/**
 *  Audio callibration offset
 */
NSTimeInterval const kAudioCallibrationOffset       = -60.0;    // milliseconds

/**
 *  Other media callibration offset
 */
NSTimeInterval const kWebCallibrationOffset        = 0.0;  // milliseconds



//------------------------------------------------------------------------------
#pragma mark - Keys and Contexts for Key Value Observation
//------------------------------------------------------------------------------

static void *AudioSyncControllerContext         = &AudioSyncControllerContext;
static void *AudioObjectTimelineContext         = &AudioObjectTimelineContext;
static void *WallClockContext                   = &WallClockContext;
static void *TVTimelineContext                  = &TVTimelineContext;


//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Synchroniser's emitted event notifications
 */
NSString* const  kSynchroniserStateNotification           =   @"SynchroniserStateNotification";
NSString* const  kSynchroniserSyncAccuracyNotification    =   @"SynchroniserSyncAccuracyNotification";
NSString* const  kSynchroniserNewContentIdNotification  = @"SynchroniserNewContentIdNotification";
NSString* const  kSynchroniserSyncTimelinesAvailableNotification = @"SynchroniserSyncTimelinesAvailableNotification";

//------------------------------------------------------------------------------
#pragma mark - Interface extensions
//------------------------------------------------------------------------------

@interface Synchroniser ()

//------------------------------------------------------------------------------
#pragma mark - access permissions redefinition
//------------------------------------------------------------------------------

@property (nonatomic, readwrite) NSString              *contentId;
@property (nonatomic, readwrite) NSString              *contentIdStatus;
@property (nonatomic, readwrite) NSString              *presentationStatus;
@property (nonatomic, readwrite) NSArray               *availableTimelines;
@property (nonatomic, readwrite) NSString              *MRS_URL;
@property (nonatomic, readwrite) NSString              *WC_URL;
@property (nonatomic, readwrite) NSString              *TS_URL;
@property (nonatomic, readwrite) TunableClock          *wallclock;
@property (nonatomic, readwrite) CorrelatedClock       *syncTimeline;
@property (nonatomic, readwrite) NSTimeInterval        error;
@property (nonatomic, readwrite) SynchroniserState     state;

//------------------------------------------------------------------------------
#pragma mark - Object-scope Properties
//------------------------------------------------------------------------------

/**
 *  The selected master device's CSS-TS server endpoint
 */
@property (nonatomic, readwrite) NSString           *App2App_URL;

/**
 *  A monotonic system clock to drive time progress on WallClock
 */
@property (nonatomic, readwrite) SystemClock            *sysCLK;

/**
 *  An algorithm for processing CSS-WC candidate measurements CSS-WC
 */
@property (nonatomic, readwrite) id<IWCAlgo>            algorithm;

/**
 *  A filter to reject unsuitable CSS-WC candidate measurements
 */
@property (nonatomic, readwrite) id<IFilter>            filter;

/**
 *  A list of filters to reject unsuitable CSS-WC candidate measurements
 */
@property (nonatomic, readwrite) NSMutableArray         *filterList;

/**
 *  A wallclock synchronisation  object. It uses the CSS-WC protocol for time sync.
 */
@property (nonatomic, readwrite) WallClockSynchroniser  *wallclock_syncer;


/**
 *  The companion's Synchronisation Timeline synchroniser. Uses CSS-TS to maintain an estimate of the TV's timeline (also called the Synchronisation Timeline).
 The local estimate of the Synchronisation Timeline is a `CorrelatedClock` as specified by the `syncTimeline` property of this class.
 */
@property (nonatomic, readwrite) TimelineSynchroniser   *tvTimelineSyncer;

/**
 *  List of media players and web views to synchronise
 */
@property (nonatomic, readwrite) NSMutableArray         *mediaPlayerObjectList;

/**
 *  List of media players and web views to synchronise
 */
@property (nonatomic, readwrite) NSMutableArray         *syncControllerList;

/**
 *  Configuration settings
 */
@property (nonatomic, readwrite) SyncKitGlobals         *config;

/**
 *  A DVB CSS-CII protocol client reporting CII updates via a NotificationCenter
 */
@property (nonatomic, readwrite) CIIClient              *cssCIIClient;


/**
 *  The selected master device's URL for interdevice synchronisation (CSS-CII endpoint)
 */
@property(nonatomic, readwrite) NSString                *interDevSyncURL;

/**
 *  A string specifying the type of timeline to select for synchronisation.
 *
 */
@property(nonatomic, readwrite) TimelineOption          *syncTimelineProperties;


@end


//------------------------------------------------------------------------------
#pragma mark - Synchroniser implementation
//------------------------------------------------------------------------------

@implementation Synchroniser
{

    dispatch_source_t   syncAccuracyTimer;
    CII *currentCII;
}



//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------

/**
 *  Create a singleton instance of a Synchroniser
 *
 *  @return Synchroniser instance
 */
+(instancetype) getInstance
{
    static Synchroniser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Synchroniser alloc] init];
    });
    return instance;

}

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                           TimelineSelector:(TimelineOption*) timeline_properties
                                   Delegate:(id<SynchroniserDelegate>) delegate
{
    return [self initWithInterDeviceSyncURL:cii_service_url
                                 App2AppURL:app2app_url
                               MediaObjects:nil
                           TimelineSelector:timeline_properties
                                   Delegate:delegate];
}

//------------------------------------------------------------------------------

- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                           TimelineSelector:(TimelineOption*) timeline_properties
{
    return [self initWithInterDeviceSyncURL:cii_service_url
                                 App2AppURL:app2app_url
                               MediaObjects:nil
                           TimelineSelector:timeline_properties
                                   Delegate:nil];
}

//------------------------------------------------------------------------------
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                               MediaObjects:(NSArray*) media_object_list
                           TimelineSelector:(TimelineOption*) timeline_properties
{
    return [self initWithInterDeviceSyncURL:cii_service_url
                                 App2AppURL:app2app_url
                               MediaObjects:media_object_list
                           TimelineSelector:timeline_properties
                                   Delegate:nil];
    
}

//------------------------------------------------------------------------------
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                               MediaObjects:(NSArray*) media_object_list
                           TimelineSelector:(TimelineOption*) timeline_properties
                                   Delegate:(id<SynchroniserDelegate>) delegate
{
    return [self initWithInterDeviceSyncURL:cii_service_url
                                 App2AppURL:nil
                               MediaObjects:media_object_list
                           TimelineSelector:timeline_properties
                                   Delegate:delegate];
}

//------------------------------------------------------------------------------

- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                               MediaObjects:(NSArray*) media_object_list
                           TimelineSelector:(TimelineOption*) timeline_properties
                                   Delegate:(id<SynchroniserDelegate>) delegate
{
    self = [super init];
    
    if (self != nil)
    {
        self.interDevSyncURL =  [cii_service_url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        self.App2App_URL = app2app_url;
        
        if (media_object_list){
            self.mediaPlayerObjectList = [NSMutableArray arrayWithArray:media_object_list];
        }else
        {
             self.mediaPlayerObjectList = [[NSMutableArray alloc] init];
        }
        
        self.syncTimelineProperties = timeline_properties;
        self.delegate = delegate;
        self.config = [SyncKitGlobals getInstance];
        assert(_config!=nil);
        
        self.cssCIIClient = [[CIIClient alloc] initWithCIIURL:self.interDevSyncURL];
        
        self.state = SynchroniserInitialised;
        
        self.sendNotifications = NO;
        
        syncAccuracyTimer = nil;
        
       
        self.syncControllerList = [[NSMutableArray alloc] init];
        
        self.syncTimelineOffset = kVideoCallibrationOffset; // a default callibration offset, it will be updated later
    }
    
    return self;
}


//------------------------------------------------------------------------------
#pragma mark - setters
//------------------------------------------------------------------------------

- (void) setState:(SynchroniserState)state
{
    
    _state = state;
    
    __weak Synchroniser *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_delegate) {
            [_delegate Synchroniser:weakSelf DidChangeState:state];
        }
        
        if (weakSelf.sendNotifications) {
            [weakSelf notifyObservers:kSynchroniserStateNotification
                               object:weakSelf
                             userInfo:@{kSynchroniserStateNotification: [NSNumber numberWithUnsignedInteger: _state]}];
        }
    });
}


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------


- (void) enableSynchronisation:(float) syncThreshold Error:(NSError** ) error
{
    self.syncThreshold = syncThreshold;
    // --- 1. start CSS-CII protocol client to receive CII messages ----
    
    [self registerForCIINotifications];
    
    if (_cssCIIClient)
        [_cssCIIClient start];
    
    
}

//------------------------------------------------------------------------------

- (void) disableSynchronisation:(NSError**) error
{
    // remove all registered media objects (also destroys their SyncControllers
    for (MediaPlayerObject *mediaObj in self.mediaPlayerObjectList) {
        [self removeMediaObject:mediaObj];
    }
    
    [self stopTimelineSync];
    
    [self stopWallClockSync];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_cssCIIClient stop];
    
    
    
}

//------------------------------------------------------------------------------

- (BOOL) addMediaObject:(MediaPlayerObject*) media_obj
{
    
    // add media object to mediasynchroniser list
    // if a synchronisation timeline is available, then set up a synccontroller
    
    
    if (![self isMediaPlayerObjectRegistered:media_obj])
    {
        MWLogDebug(@"Synchroniser.addMediaObject: media player object %@ added to synchroniser", media_obj.mediaURL);
        [self.mediaPlayerObjectList addObject:media_obj];
    }
       
    
    if (_syncTimeline)
    {
        if (_syncTimeline.available)
        {
            // set up a sync controller for this media object
            [self setUpSyncController:(MediaPlayerObject*) media_obj
                         SyncTimeline:self.syncTimeline
                      AndSyncInterval:kDefaultResyncInterval];
        }
    }
    
    
    return YES;
}

//------------------------------------------------------------------------------


- (BOOL) isMediaPlayerObjectRegistered:(MediaPlayerObject*) media_obj
{
    for (MediaPlayerObject* mediaObject in self.mediaPlayerObjectList)
    {
        if ([mediaObject isEqual:media_obj])
            return YES;
    }
    return NO;
}


//------------------------------------------------------------------------------
- (BOOL) removeMediaObject:(MediaPlayerObject*) media_obj
{
    
    
    NSUInteger index = [self.mediaPlayerObjectList indexOfObject:media_obj];
    
    if (index != NSNotFound){
        [self.mediaPlayerObjectList removeObjectAtIndex:index];
        MWLogDebug(@"Synchroniser.removeMediaObject: removed media object %@  from media object list.", media_obj.mediaURL);
    }
    
    
    // check to see if there are running or paused/stopped sync controllers for this media player object
    
    
    id syncController = [self lookUpSyncController:media_obj.mediaPlayer
                                             Class:[media_obj.mediaPlayer class]];
    
    if (syncController)
    {
        // stop the sync controller
        MWLogDebug(@"Synchroniser.removeMediaObject: stopping synccontroller for %@ ", media_obj.mediaURL);
        
        if ([syncController class] == [VideoPlayerSyncController class])
        {
            [((VideoPlayerSyncController*) syncController) stop];
            
            
        }else if ([syncController class] == [AudioSyncController class])
        {
            
            [((AudioSyncController*) syncController) stop];
            
        }else if ([syncController class] == [WebViewSyncController class])
        {
            [((WebViewSyncController*) syncController) stop];
            
        }
        
        
        // remove from mediasynchroniser list of sync controllers
        
        [self.syncControllerList removeObject:syncController];
        
        MWLogDebug(@"Synchroniser.removeMediaObject: SyncController for %@ removed from list.", media_obj.mediaURL);
        
        
        syncController = nil;
    }
    
    return YES;
}


//------------------------------------------------------------------------------
#pragma mark - CII private methods
//------------------------------------------------------------------------------

- (void) handleCIINotifications:(NSNotification*) notification
{
     NSUInteger ciiChangeStatus=0;
    
    
    
     // --- 2. Handle new CII and start WallClock synchronisation ----
    
    if  ([[notification name] caseInsensitiveCompare:kCIIDidChange] == 0) {
        
        id temp = [[notification userInfo] objectForKey:kCIIDidChange];
        
        NSNumber *status = [[notification userInfo] objectForKey:kCIIChangeStatusMask];
        
        if (status) {
            ciiChangeStatus = [status unsignedIntegerValue];
        }
        
        MWLogDebug(@"Synchroniser: Received New CII notification ... ");
        
        if (ciiChangeStatus & NewCIIReceived)
        {

            if ([temp isKindOfClass:[CII class]])
            {
                currentCII = temp;
                self.contentId = currentCII.contentId;
                self.contentIdStatus = currentCII.contentIdStatus;
                self.presentationStatus = currentCII.presentationStatus;
                self.availableTimelines = [currentCII.timelines copy];
                self.WC_URL = currentCII.wcUrl;
                self.MRS_URL = currentCII.msrUrl;
                self.TS_URL = currentCII.tsUrl;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                     NSMutableDictionary *paramsDict;
                    
                    [self.delegate Synchroniser:self
                          NewContentInfoAvailable: currentCII
                                       ChangeMask:ciiChangeStatus];
                    if (_sendNotifications)
                    {
                        paramsDict = [[NSMutableDictionary alloc] init];
                        [paramsDict setObject:currentCII forKey:kSynchroniserNewContentIdNotification];
                        
                        [self notifyObservers:kSynchroniserNewContentIdNotification object:self userInfo:paramsDict];
                        
                        if (currentCII.timelines)
                        {
                            
                            [paramsDict setObject:currentCII forKey:kSynchroniserSyncTimelinesAvailableNotification];
                            
                            [self notifyObservers:kSynchroniserSyncTimelinesAvailableNotification object:self userInfo:paramsDict];
                        }
                        
                    }
                });
                
                // 3 ---- start WallClock Synchronisation ---
                [self startWallClockSync];
                
            }
        }
        
        if (ciiChangeStatus  & ContentIdChanged) {
            
            if ([temp isKindOfClass:[CII class]])
            {
                currentCII = temp;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 NSMutableDictionary *paramsDict;
                
                [self.delegate Synchroniser:self
                      NewContentInfoAvailable: currentCII
                                   ChangeMask:ciiChangeStatus];
                if (_sendNotifications)
                {
                    paramsDict = [[NSMutableDictionary alloc] init];
                    [paramsDict setObject:currentCII forKey:kSynchroniserNewContentIdNotification];
                    
                    [self notifyObservers:kSynchroniserNewContentIdNotification object:self userInfo:paramsDict];
                    
                    if (currentCII.timelines)
                    {
                        
                        [paramsDict setObject:currentCII forKey:kSynchroniserSyncTimelinesAvailableNotification];
                        
                        [self notifyObservers:kSynchroniserSyncTimelinesAvailableNotification object:self userInfo:paramsDict];
                    }
                    
                }

            });
            
            // Content Id has changed, launch new timeline synchronisation
            // new content id is picked in currentCII object by startTimelineSync()
            
            if (_tvTimelineSyncer)
                [self stopTimelineSync];
            
            [self startTimelineSync];
 
        }
    }
    
    
    
}

//------------------------------------------------------------------------------

- (void) registerForCIINotifications
{
    
    // --- register for CIIProtocolClient notifications ---
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIConnectionFailure object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIDidChange object:nil];
}



//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Start/Stop Sync private methods
//------------------------------------------------------------------------------

/**
 *  Start WallClock Synchronisation and register Synchroniser as observer of WallClock state changes
 */
- (void)startWallClockSync {
    
    // create a System clock with tickrate = 1 billion
    _sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    _wallclock = [[TunableClock alloc] initWithParentClock:_sysCLK TickRate:_kOneThousandMillion Ticks:[_sysCLK ticks]];
    
    _algorithm = [[LowestDispersionAlgorithm alloc] initWithWallClock:_wallclock];
    _filter = [[RTTThresholdFilter alloc] initWithThreshold:100];
    _filterList = [NSMutableArray arrayWithObject:_filter];
    
    
    NSArray *urlParts = [self.WC_URL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":/"]];
    
    NSNumber *number = [NSNumber numberWithLongLong: [urlParts[4] longLongValue]];
    int port = number.intValue;
    
    _wallclock_syncer = [[WallClockSynchroniser alloc] initWithWCServer:urlParts[3]
                                                                   Port:port WallClock:_wallclock
                                                              Algorithm:_algorithm
                                                             FilterList:_filterList];
    [_wallclock addObserver:self forKeyPath:kAvailableKey options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:WallClockContext];
    
    // --- start WallClock Sync ----
    [_wallclock_syncer start];

}

//------------------------------------------------------------------------------

- (void) stopWallClockSync
{
    [_wallclock_syncer stop];
    [_wallclock removeObserver:self forKeyPath:kAvailableKey];
}


//------------------------------------------------------------------------------

/**
 *  Start timeline synchronisation
 */
- (void)startTimelineSync {
    
    // -- start Timeline Sync ----
    
    // if content id was null, don't start timeline sync
    if (isNull(currentCII.contentId))
        return;
    
    // create a timeline object to synchronise
    Correlation corel = [CorrelationFactory create:0 Correlation:0];
    
    uint64_t tickrate = [self.syncTimelineProperties.timelineProperties.unitsPerSecond unsignedLongLongValue];

    _syncTimeline = [[CorrelatedClock alloc] initWithParentClock:_wallclock
                                                         TickRate:tickrate
                                                      Correlation:&corel]; // timeline created but unavailable
    
    self.tvTimelineSyncer = [TimelineSynchroniser TimelineSynchroniserWithTimeline:self.syncTimeline
                                                                 TimelineSelector:self.syncTimelineProperties.timelineSelector
                                                                          Content:currentCII.contentId
                                                                              URL:self.TS_URL
                                                                           Offset:self.syncTimelineOffset];
    assert(_tvTimelineSyncer!=nil);
    
    _tvTimelineSyncer.delegate = self;
    
    [_syncTimeline addObserver:self context:TVTimelineContext];
    
    [_tvTimelineSyncer start];
    
    self.state = SynchroniserSyncEnabled;
}

//------------------------------------------------------------------------------

- (void)stopTimelineSync {
    
    
//    dispatch_source_cancel(UIUpdateTimer);
    if (_tvTimelineSyncer){
        [_tvTimelineSyncer stop];
        [_syncTimeline removeObserver:self Context:TVTimelineContext ];
        _tvTimelineSyncer.delegate = nil;
        _tvTimelineSyncer= nil;
        _syncTimeline= nil;
    }
    
    
    self.state = SynchroniserSyncDisabled;
}


//------------------------------------------------------------------------------

dispatch_source_t CreateDispatchTimer(uint64_t interval,
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

- (void) startSyncControllers
{
    
    
    
    
}


//------------------------------------------------------------------------------

- (void) reportSyncAccuracy
{
//    int64_t tempDisp = [self.wallclock_syncer getCurrentDispersion];
//    NSTimeInterval dispersion = (Float64)tempDisp/1000000.0;
    
    int64_t tempDisp = [_wallclock dispersionAtTime: [_wallclock nanoSeconds]];
    NSTimeInterval dispersion = (Float64)tempDisp/1000000.0;
    
    if ((_delegate) && (dispersion > self.syncThreshold))
    {
        [_delegate Synchroniser:self SyncAccuracy:dispersion];
        if (self.sendNotifications)
        {
            [self notifyObservers:kSynchroniserSyncAccuracyNotification
                           object:self
                         userInfo:@{kSynchroniserSyncAccuracyNotification:                                    [NSNumber numberWithDouble: dispersion]}];
        }
    }
    
    
}


//------------------------------------------------------------------------------


/**
 *  @brief Sets up a sync controller for the media player if there is not already one. Creates
 *  a VideoPlayerSyncController object for a video player (VideoPlayerViewController instance),
 *  an AudioSyncController for an audio player (AudioPlayer instance) and
 *  a WebViewSyncController for a web view (UIWebView).
 *
 *  @discussion  This method is invoked when the synchronisation timeline's (syncTimeline object) 'Available'
 *  property becomes true.
 *
 *  @param mediaplayerobj  a container object for a media player, its media URL and its correlation 
 *  with the synchronisation timeline
 *  @param sync_timeline   synchronisation timeline
 *  @param resync_interval interval for sync controller to resync
 */
- (void) setUpSyncController:(MediaPlayerObject*) mediaplayerobj
                     SyncTimeline:(CorrelatedClock*) sync_timeline
                   AndSyncInterval:(NSTimeInterval) resync_interval
{
    if ([mediaplayerobj.mediaPlayer class] == [VideoPlayerViewController class])
    {
        VideoPlayerViewController* videoplayer = (VideoPlayerViewController*) mediaplayerobj.mediaPlayer;
        
        // check if there is an existing sync controller for this video player
        VideoPlayerSyncController* vSyncController = [self lookUpSyncController:mediaplayerobj.mediaPlayer
                                                                          Class:[VideoPlayerViewController class]];
        if (!vSyncController)
        {
            
            Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
            
            // create a new sync controller of type VideoPlayerSyncController
            // start sync controller and add to our list of sync controllers
            vSyncController = [VideoPlayerSyncController
                               syncControllerWithVideoPlayer:videoplayer
                               SyncTimeline:sync_timeline
                               CorrelationTimestamp:&corel
                               SyncInterval:resync_interval
                               AndDelegate:self];
            [self.syncControllerList addObject:vSyncController];
            [vSyncController start];
            
            
            MWLogDebug(@"Synchroniser.setUpSyncController: sync controller created for media player object %@ ", mediaplayerobj.mediaURL);

        }else
        {
            // check state for sync controller

            if (vSyncController.state == VideoSyncCrtlPaused){
                [vSyncController start];
                 MWLogDebug(@"Synchroniser.setUpSyncController: Paused sync controller for media player object %@ started", mediaplayerobj.mediaURL);
            }
            else if (vSyncController.state == VideoSyncCrtlStopped)
            {
                
                [self.syncControllerList removeObject:vSyncController];
                
                Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
                
                vSyncController = [VideoPlayerSyncController
                                   syncControllerWithVideoPlayer:videoplayer
                                   SyncTimeline:sync_timeline
                                   CorrelationTimestamp:&corel
                                   SyncInterval:resync_interval
                                   AndDelegate:self];
                
                [self.syncControllerList addObject:vSyncController];
                [vSyncController start];
                
                MWLogDebug(@"Synchroniser.setUpSyncController: stopped sync controller for media player object %@ restarted", mediaplayerobj.mediaURL);
            }
        }
    
    }else if ([mediaplayerobj.mediaPlayer class] == [AudioPlayer class])
    {
        
        AudioPlayer* audioplayer = (AudioPlayer*) mediaplayerobj.mediaPlayer;
        
        // check if there is an existing sync controller for this video player
        AudioSyncController* aSyncController = [self lookUpSyncController:mediaplayerobj.mediaPlayer
                                                                          Class:[AudioPlayer class]];
        if (!aSyncController)
        {
            
             Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
            
            // create a new sync controller of type VideoPlayerSyncController
            // start sync controller and add to our list of sync controllers
            aSyncController = [AudioSyncController syncControllerWithAudioPlayer:audioplayer
                                                                    SyncTimeline:sync_timeline
                                                            CorrelationTimestamp:&corel
                                                                    SyncInterval:resync_interval
                                                                     AndDelegate:self];
            [self.syncControllerList addObject:aSyncController];
            [aSyncController start];
            
            MWLogDebug(@"Synchroniser.setUpSyncController: sync controller created for media player object %@ ", mediaplayerobj.mediaURL);

            
        }else
        {
            // check state for sync controller
            
            if (aSyncController.state == AudioSyncCrtlPaused){
                [aSyncController start];
                MWLogDebug(@"Synchroniser.setUpSyncController: Paused sync controller for media player object %@ started", mediaplayerobj.mediaURL);
            }
            else if (aSyncController.state == AudioSyncCrtlStopped)
            {
                 [self.syncControllerList removeObject:aSyncController];
                
                Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
                
                aSyncController = [AudioSyncController syncControllerWithAudioPlayer:audioplayer
                                                                        SyncTimeline:sync_timeline
                                                                CorrelationTimestamp:&corel
                                                                        SyncInterval:resync_interval
                                                                         AndDelegate:self];
                [self.syncControllerList addObject:aSyncController];
                [aSyncController start];
                MWLogDebug(@"Synchroniser.setUpSyncController: stopped sync controller for media player object %@ restarted", mediaplayerobj.mediaURL);
            }
        }

    }
    else if ([mediaplayerobj.mediaPlayer class] == [AudioPlayerViewController class])
    {
        
        AudioPlayerViewController* audioplayerVC = (AudioPlayerViewController*) mediaplayerobj.mediaPlayer;
        
        // check if there is an existing sync controller for this video player
        AudioSyncController* aSyncController = [self lookUpSyncController:mediaplayerobj.mediaPlayer
                                                                    Class:[AudioPlayerViewController class]];
        if (!aSyncController)
        {
            // create a new sync controller of type VideoPlayerSyncController
            // start sync controller and add to our list of sync controllers
            
             Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
            aSyncController = [AudioSyncController syncControllerWithAudioPlayer:audioplayerVC.player
                                                                    SyncTimeline:sync_timeline
                                                            CorrelationTimestamp:&corel
                                                                    SyncInterval:resync_interval
                                                                     AndDelegate:self];
            [self.syncControllerList addObject:aSyncController];
            [aSyncController start];
            
            MWLogDebug(@"Synchroniser.setUpSyncController: sync controller created for media player object %@ ", mediaplayerobj.mediaURL);

            
        }else
        {
            // check state for sync controller
            
            if (aSyncController.state == AudioSyncCrtlPaused){
                [aSyncController start];
                MWLogDebug(@"Synchroniser.setUpSyncController: Paused sync controller for media player object %@ started", mediaplayerobj.mediaURL);
            }
            else if (aSyncController.state == AudioSyncCrtlStopped)
            {
                
                [self.syncControllerList removeObject:aSyncController];
                Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
                aSyncController = [AudioSyncController syncControllerWithAudioPlayer:audioplayerVC.player
                                                                        SyncTimeline:sync_timeline
                                                                CorrelationTimestamp:&corel
                                                                        SyncInterval:resync_interval
                                                                         AndDelegate:self];
                [self.syncControllerList addObject:aSyncController];
                [aSyncController start];
                MWLogDebug(@"Synchroniser.setUpSyncController: stopped sync controller for media player object %@ restarted", mediaplayerobj.mediaURL);
            }
        }
        
    }else if ([mediaplayerobj.mediaPlayer class] == [UIWebView class])
    {
        UIWebView* webview = (UIWebView*) mediaplayerobj.mediaPlayer;
        
        // check if there is an existing sync controller for this video player
        WebViewSyncController* wSyncController = [self lookUpSyncController:mediaplayerobj.mediaPlayer
                                                                    Class:[UIWebView class]];
        if (!wSyncController)
        {
            // create a new sync controller of type VideoPlayerSyncController
            // start sync controller and add to our list of sync controllers
             Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
            wSyncController = [WebViewSyncController syncControllerWithUIWebView:webview
                                                                             URL:[NSURL URLWithString:mediaplayerobj.mediaURL]
                                                                    SyncTimeline:sync_timeline
                                                            CorrelationTimestamp:&corel
                                                                    SyncInterval:2.0 AndDelegate:self];
            wSyncController.app2AppURL = self.App2App_URL;
            wSyncController.contentId = currentCII.contentId;
            [self.syncControllerList addObject:wSyncController];
            [wSyncController start];
            MWLogDebug(@"Synchroniser.setUpSyncController: sync controller created for media player object %@ ", mediaplayerobj.mediaURL);
        }else
        {
            // check state for sync controller
            
            if (wSyncController.state == WebSyncCrtlPaused){
                wSyncController.contentId = currentCII.contentId;
                [wSyncController start];
                 MWLogDebug(@"Synchroniser.setUpSyncController: Paused sync controller for media player object %@ started", mediaplayerobj.mediaURL);
            }
            else if (wSyncController.state == WebSyncCrtlStopped)
            {
                [self.syncControllerList removeObject:wSyncController];
                Correlation corel = [CorrelationFactory create:mediaplayerobj.correlation.parentTickValue Correlation:mediaplayerobj.correlation.tickValue];
                
                wSyncController = [WebViewSyncController syncControllerWithUIWebView:webview
                                                                                 URL:[NSURL URLWithString:mediaplayerobj.mediaURL]
                                                                        SyncTimeline:sync_timeline
                                                                CorrelationTimestamp:&corel
                                                                        SyncInterval:2.0 AndDelegate:self];
                wSyncController.app2AppURL = self.App2App_URL;
                wSyncController.contentId = currentCII.contentId;
                [self.syncControllerList addObject:wSyncController];
                [wSyncController start];
                MWLogDebug(@"Synchroniser.setUpSyncController: stopped sync controller for media player object %@ restarted", mediaplayerobj.mediaURL);
            }
        }
    }
}

//------------------------------------------------------------------------------

/**
 *  Looks up a sync controller for the media player and its type
 *
 *  @param mediaPlayer polymorphic argument for a VideoPlayerViewController, AudioPlayer or UIWebView instance
 *  @param playerClass the type of the player
 *
 *  @return a VideoPlayerViewController, AudioSyncController or WebViewSyncController instance if found, else nil is returned.
 */
- (id) lookUpSyncController:(id) mediaPlayer Class:(Class) playerClass
{
    
    if (playerClass == [VideoPlayerViewController class])
    {
        
        VideoPlayerViewController* videoplayer = (VideoPlayerViewController*) mediaPlayer;
        
        for (id syncController in self.syncControllerList)
        {
            
            if ([syncController class] == [VideoPlayerSyncController class] )
            {
                VideoPlayerSyncController* vSyncController = (VideoPlayerSyncController *) syncController;
                
                if (mediaPlayer == vSyncController.videoPlayer)
                    return vSyncController;
            } // end if
        } // end for
        
        
    }else if (playerClass == [AudioPlayer class])
    {
        AudioPlayer* audioplayer = (AudioPlayer*) mediaPlayer;
        
        for (id syncController in self.syncControllerList)
        {
            
            if ([syncController class] == [AudioSyncController class] )
            {
                AudioSyncController* aSyncController = (AudioSyncController *) syncController;
                
                if (audioplayer == aSyncController.audioPlayer)
                    return aSyncController;
            }// end if
        } // end for
    }
    else if (playerClass == [AudioPlayerViewController class])
    {
        AudioPlayerViewController* audioplayerVC = (AudioPlayerViewController*) mediaPlayer;
        
        for (id syncController in self.syncControllerList)
        {
            if ([syncController class] == [AudioSyncController class] )
            {
                AudioSyncController* aSyncController = (AudioSyncController *) syncController;
                
                if (audioplayerVC.player == aSyncController.audioPlayer)
                    return aSyncController;
            }// end if
        } // end for
    }else if (playerClass ==  [UIWebView class])
    {
        UIWebView* webview = (UIWebView*) mediaPlayer;
        
        for (id syncController in self.syncControllerList)
        {
            if ([syncController class] == [WebViewSyncController class] )
            {
                WebViewSyncController* wSyncController = (WebViewSyncController *) syncController;
                
                if (webview == wSyncController.webView)
                    return wSyncController;
            }// end if
        } // end for
    }// end if (playerClass == [VideoPlayerViewController class])
    
    
    
    return nil;
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - KVO for WallClock and TVTimeline
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
     if (context == WallClockContext) {
        
        // ----- WallClock KVO ------
        if ([keyPath isEqualToString:kAvailableKey])
        {
            // 4. If WallClock is available, start timeline synchronisation
            BOOL newAvailability = [[change objectForKey:@"new"] boolValue];
            [self wallClock:self.wallclock AvailabilityDidChange:newAvailability];
            
            
        } // end if
    }
    else if (context == TVTimelineContext) {
        
        // ----- SyncTimeline clock KVO ------
        if ([keyPath isEqualToString:kTickRateKey])
        {
            // do nothing
            
        }else if ([keyPath isEqualToString:kSpeedKey])
        {
            [self syncTimeline:self.syncTimeline SpeedDidChange:[[change objectForKey:@"new"] floatValue]];
            
        }else if([keyPath isEqualToString:kCorrelationKey]) {
           
            Correlation newCorel;
            id newobj = [change objectForKey:@"new"];
            if ([newobj isKindOfClass:[NSValue class]])
            {
               [newobj getValue:&newCorel];
                [self syncTimeline:self.syncTimeline CorrelationDidChange:&newCorel];
            }

        }else if ([keyPath isEqualToString:kAvailableKey]) {
            
            // 4. If SyncTimeline is available, start timeline synchronisation
            BOOL oldTVTimelineAvailable = [[change objectForKey:@"old"]boolValue];
            BOOL newTVTimelineAvailable = [[change objectForKey:@"new"]boolValue];
            
            [self syncTimeline:self.syncTimeline AvailabilityDidChangeFrom:oldTVTimelineAvailable To:newTVTimelineAvailable];
        }
    }
}

//------------------------------------------------------------------------------

- (void) wallClock: (TunableClock*) wallclock AvailabilityDidChange:(BOOL) availability
{
    MWLogDebug(@"Synchroniser wallclock AvailabilityDidChange: %d", availability);
    // ---- 4. WallClock is available, start timeline synchronisation -----
    // only start timeline sync when wallclock is in sync
    if (availability){
        if (!_tvTimelineSyncer)
            [self startTimelineSync];
        
        if (!syncAccuracyTimer) {
            syncAccuracyTimer = CreateDispatchTimer(2000*NSEC_PER_MSEC,
                                                    1* NSEC_PER_MSEC,
                                                    dispatch_get_main_queue(),
                                                    ^{ [self reportSyncAccuracy]; });
        }
        dispatch_resume(syncAccuracyTimer);
    }else{
        // TODO: Handle WallClock becoming unavailable
        dispatch_suspend(syncAccuracyTimer);
        
        
    }

}

//------------------------------------------------------------------------------

- (void) syncTimeline: (CorrelatedClock*) sync_timeline CorrelationDidChange:(Correlation*) newCorrelation
{
     NSString* msg;
     msg = [NSString stringWithFormat:@"contentTime: %lld wallClockTime: %lld", newCorrelation->tickValue, newCorrelation->parentTickValue];
    //id oldobj = [change objectForKey:@"old"];
      NSLog(@"Synchroniser: syncTimeline correlation change: %@", msg);
    
}

//------------------------------------------------------------------------------

- (void) syncTimeline: (CorrelatedClock*) sync_timeline SpeedDidChange:(float) newSpeed
{
    // we don't need to do anything. Speed changes are propagated to the syncTimeline's child clock objects
    // these child clocks are in each of the sync controller objects.
    
    MWLogDebug(@"Synchroniser: syncTimeline speed changed.");
}

//------------------------------------------------------------------------------

- (void) syncTimeline: (CorrelatedClock*) sync_timeline
AvailabilityDidChangeFrom:(BOOL) oldAvailability
                   To:(BOOL) newAvailability
{
    
    NSString* msg;
    
    msg = [NSString stringWithFormat:@"changed from %d to %d", oldAvailability, newAvailability];
    
    MWLogDebug(@"Synchroniser: syncTimeline availability  %@", msg);
    
    if (newAvailability){
        
        self.state = SyncTimelineAvailable;
        
        // --- for every media player or web view, start a Sync Controller object ---
        for (id obj in _mediaPlayerObjectList)
        {
            [self setUpSyncController:(MediaPlayerObject*) obj
                         SyncTimeline:self.syncTimeline
                      AndSyncInterval:kDefaultResyncInterval];
        } // end for
    }else
    {
         self.state = SyncTimelineUnavailable;
        // TODO: Handle Synchronisation Timeline becoming unavailable
        // SyncController objects are already handling Synchronisation Timeline availability changes via KVO
        
    }
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


//------------------------------------------------------------------------------
#pragma mark - SyncControllerDelegate methods
//------------------------------------------------------------------------------

- (void) SyncController:(id) controller DidChangeState:(NSUInteger) state
{
    //NSLog(@"ViewController- VideoSyncControllerDelegate: %lu", (unsigned long)state);
    
    
    if ([controller class] == [VideoPlayerSyncController class])
    {
        
        VideoPlayerSyncController * vSyncController = (VideoPlayerSyncController *) controller;
        
        if (state == VideoSyncCrtlSyncTimelineAvailable) {
            
            if (![vSyncController.videoPlayer isPlaying])
            {
                [vSyncController.videoPlayer play];
            }
            
            
        }
        
        
    }else if ([controller class] == [AudioSyncController class])
    {
        
        AudioSyncController * aSyncController = (AudioSyncController *) controller;
        
        
    }else if ([controller class] == [WebViewSyncController class])
    {
        
        
        WebViewSyncController * wSyncController = (WebViewSyncController *) controller;
        
    }
    
    
    
    
    
    //    if (state == VideoSyncCrtlSynchronising) [HUD showUIBlockingIndicatorWithText:@"Synchronising with your TV ..."];
    //
    //
    
}

//------------------------------------------------------------------------------

- (void) SyncController:(id) controller
           ReSyncStatus:(NSUInteger) status
                 Jitter:(NSTimeInterval) jitter
              WithError:(SyncControllerError*) error
{

    if ([controller class] == [VideoPlayerSyncController class])
    {
        
        VideoPlayerSyncController * vSyncController = (VideoPlayerSyncController *) controller;
        
        //    if ((status == VideoSyncCrtlSynchronising) && (jitter < _vSyncController.reSyncJitterThreshold)) [HUD hideUIBlockingIndicator];
        
        
        if (_delegate)
        {
            [_delegate VideoSyncController:vSyncController ReSyncStatus:status Jitter:jitter WithError:error];
        }
        
        
    }else if ([controller class] == [AudioSyncController class])
    {
        
        AudioSyncController * aSyncController = (AudioSyncController *) controller;
        
        if (_delegate)
        {
            [_delegate AudioSyncController:aSyncController ReSyncStatus:status Jitter:jitter WithError:error];
        }
        
        
    }else if ([controller class] == [WebViewSyncController class])
    {
        
        
        WebViewSyncController * wSyncController = (WebViewSyncController *) controller;
        
    }
}



//------------------------------------------------------------------------------
#pragma mark - TimelineSynchroniserDelegate methods
//------------------------------------------------------------------------------

- (void) ts:(TimelineSynchroniser*) ts DidChangeState:(TSState) state
{
    // NSLog(@"TimelineSynchroniser state : %u", state);
}

@end
