//
//  ViewController.m
//  VideoSyncControllerDemoApp
//
//  Created by Rajiv Ramdhany on 20/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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



#import "AudioSyncDemoAppViewController.h"
#import "HUD.h"

#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"aac"]

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------


//NSString *serverAddress     = @"192.168.1.112";
//NSString *contentId         = @"dvb://233A.4084.0001";
//NSString *timelineSelector  = @"urn:dvb:css:timeline:pts";
//NSString *tsEndpointURL     = @"ws://192.168.1.112:7682";
//------------------------------------------------------------------------------

 //  --- callibration ---
//NSString *serverAddress     = @"192.168.1.106";
//NSString *contentId         = @"urn:dvbcss-synctiming:testvideo";
//NSString *timelineSelector  = @"urn:dvb:css:timeline:pts";
//NSString *tsEndpointURL     = @"ws://192.168.1.106:7681/ts";

//------------------------------------------------------------------------------

//NSString *serverAddress     = @"192.168.1.102";
//NSString *contentId         = @"dvb://233A.4084.0001";
//NSString *timelineSelector  = @"urn:dvb:css:timeline:pts";
//NSString *tsEndpointURL     = @"ws://192.168.1.102:7682";
//------------------------------------------------------------------------------

NSString *serverAddress     = @"192.168.1.128";
NSString *contentId         = @"http://127.0.0.1:8123/channel_B_video.mp4";
//NSString *timelineSelector  = @"urn:dvb:css:timeline:ct";
NSString *timelineSelector  = @"tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:5000";
NSString *tsEndpointURL     = @"ws://192.168.1.128:7681/ts";
int tick_rate = 5000;

//------------------------------------------------------------------------------
static void *WallClockContext = &WallClockContext;
static void *TVTimelineContext = &TVTimelineContext;
static void *ExpectedAudioTimelineContext = &ExpectedAudioTimelineContext;

/**
 *  The start position of the programme on the TV timeline.
 *  this is specific to the TV stream which we are synchronising to.
 */
Float64 testProgrammeStartTicks = 900000;

//------------------------------------------------------------------------------
#pragma mark - ViewController (Interface Extension)
//------------------------------------------------------------------------------



@interface AudioSyncDemoAppViewController () <TimelineSynchroniserDelegate, AudioPlayerVCDelegate, SyncControllerDelegate>


@property (nonatomic, readwrite) SystemClock             *sysCLK;
@property (nonatomic, readwrite) TunableClock            *wallclock;
@property (nonatomic, readwrite) id<IWCAlgo>             algorithm;          // an algorithm for processing candidate measurements
@property (nonatomic, readwrite) id<IFilter>             filter;             // a filter to reject unsuitable candidate measurements
@property (nonatomic, readwrite) NSMutableArray          *filterList;        // a filter list
@property (nonatomic, readwrite) WallClockSynchroniser   *wallclock_syncer;  // a wallclock synchronisation
@property (nonatomic, readwrite) CorrelatedClock         *tvPTSTimeline;     // a PTS timeline, selector = "urn:dvb:css:timeline:pts", tickrate =90000
@property (nonatomic, readwrite) TimelineSynchroniser       *tvPTSTimelineSyncer;
@property (nonatomic, readwrite) AudioPlayerViewController  *audioPlayerVC;

@property(nonatomic, readwrite) AudioSyncController         * audSyncController;


@property (weak, nonatomic) IBOutlet UIView *audioPlot;





/**
 *  Sync status
 */
@property (nonatomic, readwrite) BOOL running;

@end

@implementation AudioSyncDemoAppViewController
{
    dispatch_source_t       UIUpdateTimer;
    dispatch_source_t       reSyncTimer;
    NSURL *url;

}

//------------------------------------------------------------------------------
#pragma mark - ViewController, UI handler methods
//------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // start wallclock synchronisation
    [self startWallClockSync];
   
    
}



- (void) viewDidAppear:(BOOL)animated
{
     [HUD showUIBlockingIndicatorWithText:@"Synchronising with your TV ..."];
}
//------------------------------------------------------------------------------


- (void)dealloc
{
    [self.tvPTSTimeline removeObserver:self Context:TVTimelineContext];
}




//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - actions
//------------------------------------------------------------------------------

- (void) UIUpdateTask
{
    // read TV Timeline
    Float64 currentTVTimeSecs;
     //Float64 currentExpectedVideoTimeSecs;
    
    if (_tvPTSTimeline.available)
    {
        
        currentTVTimeSecs = ([_tvPTSTimeline time]);
        
     }else{
        currentTVTimeSecs = 0;
    }
    
    //NSLog(@"ViewController.UIUpdateTask: current TVTime %f", currentTVTimeSecs);
    NSLog(@"ViewController.UIUpdateTask: audio time %f s", self.audioPlayerVC.player.currentTime);
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



//------------------------------------------------------------------------------
#pragma mark - KVO for WallClock and TVTimeline
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if (context == WallClockContext) {
        if ([keyPath isEqualToString:kAvailableKey])
        {
            NSNumber *newAvailability = [change objectForKey:@"new"];
            
            // only start timeline sync when wallclock is in sync
            if (([newAvailability boolValue] == YES) && (_tvPTSTimelineSyncer==nil)){
                [self startTimelineSync];
            }
            
        }
     }
    else if (context == TVTimelineContext) {
        NSString* msg;
        
        if ([keyPath isEqualToString:kTickRateKey]) {
            
            
        }else if ([keyPath isEqualToString:kSpeedKey]) {
            
            NSLog(@"ViewController: tvPTSTimeline speed changed.");
            
        }else if([keyPath isEqualToString:kCorrelationKey]) {
//            NSLog(@"ViewController: tvPTSTimeline correlation changed.");
            
            
            Correlation newCorel;
            
            //id oldobj = [change objectForKey:@"old"];
            id newobj = [change objectForKey:@"new"];
            
            
            if ([newobj isKindOfClass:[NSValue class]])
            {
                [newobj getValue:&newCorel];
                msg = [NSString stringWithFormat:@"contentTime: %lld wallClockTime: %lld", newCorel.tickValue, newCorel.parentTickValue];
            }
             NSLog(@"ViewController: tvPTSTimeline correlation change: %@", msg);
            
        }else if ([keyPath isEqualToString:kAvailableKey]) {
            
            
            
            BOOL oldTVTimelineAvailable = [[change objectForKey:@"old"]boolValue];
            BOOL newTVTimelineAvailable = [[change objectForKey:@"new"]boolValue];
            
            msg = [NSString stringWithFormat:@"changed from %d to %d", oldTVTimelineAvailable, newTVTimelineAvailable];
            
            NSLog(@"ViewController: tvPTSTimeline availability  %@", msg);
            
            if (newTVTimelineAvailable){
                
                // start the video player
                [self startAudio];

                [HUD showUIBlockingIndicatorWithText:@"Synchronising with your TV ..."];
                
                // setup a sync controller for video player
                Correlation corel = [CorrelationFactory create:0 Correlation:0];
                
                self.audSyncController = [AudioSyncController syncControllerWithAudioPlayer:self.audioPlayerVC.player
                                                                               SyncTimeline:self.tvPTSTimeline
                                                                       CorrelationTimestamp:&corel
                                                                               SyncInterval:4.0
                                                                                AndDelegate:self];

                [self.audSyncController start];
            }
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - TimelineSynchroniserDelegate methods
//------------------------------------------------------------------------------

- (void) ts:(TimelineSynchroniser*) ts DidChangeState:(TSState) state
{
   // NSLog(@"TimelineSynchroniser state : %lu", (unsigned long)state);
}



//------------------------------------------------------------------------------
#pragma mark - private methods
//------------------------------------------------------------------------------

/**
 *  Start WallClock Synchronisation
 */
- (void)startWallClockSync {
    
    // create a System clock with tickrate = 1 billion
   _sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    // --- start WallClock Sync ----
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    _wallclock = [[TunableClock alloc] initWithParentClock:_sysCLK TickRate:_kOneThousandMillion Ticks:[_sysCLK ticks]];
    
    _algorithm = [[LowestDispersionAlgorithm alloc] initWithWallClock:_wallclock];
    _filter = [[RTTThresholdFilter alloc] initWithThreshold:100];
    _filterList = [NSMutableArray arrayWithObject:_filter];
    
    _wallclock_syncer = [[WallClockSynchroniser alloc] initWithWCServer:serverAddress
                                                                  Port:6677 WallClock:_wallclock
                                                             Algorithm:_algorithm
                                                            FilterList:_filterList];
    [_wallclock addObserver:self forKeyPath:kAvailableKey options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:WallClockContext];
    
    [_wallclock_syncer start];
}

//------------------------------------------------------------------------------

/**
 *  Start timeline synchronisation
 */
- (void)startTimelineSync {
    // -- start Timeline Sync ----
    // create a timeline object to synchronise
    Correlation corel = [CorrelationFactory create:0 Correlation:0];
    _tvPTSTimeline = [[CorrelatedClock alloc] initWithParentClock:_wallclock
                                                        TickRate:tick_rate
                                                     Correlation:&corel]; // timeline created but unavailable
    
    _tvPTSTimelineSyncer = [TimelineSynchroniser TimelineSynchroniserWithTimeline:_tvPTSTimeline
                                                                TimelineSelector:timelineSelector
                                                                         Content:contentId
                                                                             URL:tsEndpointURL
                                                                           Offset:-60.0];
    assert(_tvPTSTimelineSyncer!=nil);
    
    _tvPTSTimelineSyncer.delegate = self;
    
    [_tvPTSTimeline addObserver:self context:TVTimelineContext];
    
    
    [_tvPTSTimelineSyncer start];
    
    self.running = true;
    
    
    
}

//------------------------------------------------------------------------------

- (void)stopTimelineSync {
    
    
    dispatch_source_cancel(UIUpdateTimer);
    
    [_tvPTSTimelineSyncer stop];
    [_tvPTSTimeline removeObserver:self Context:TVTimelineContext ];
    _tvPTSTimelineSyncer= nil;
    _tvPTSTimeline= nil;
    UIUpdateTimer = nil;
    
    
    self.running = false;
}

//------------------------------------------------------------------------------


- (void) startAudio
{
    if (self.audioPlayerVC)
    {
        
        [self.audioPlayerVC stopPlayerAndRemoveView];
        self.audioPlayerVC =  nil;
        
    }
    
    self.audioPlayerVC = [[AudioPlayerViewController alloc] initWithAudioFilePath:kAudioFileDefault ParentView:self.audioPlot Delegate:self];
    
    
}

//------------------------------------------------------------------------------

- (void) toggleAudioPlayerPlay
{
    if (self.audioPlayerVC.player.state == AudioPlayerStatePlaying)
    {
        [self.audioPlayerVC.player pause];
        
    }else if (self.audioPlayerVC.player.state == AudioPlayerStatePaused)
    {
        [self.audioPlayerVC.player play];
    }
}

//------------------------------------------------------------------------------

- (void) stopAudio
{
    if (self.audioPlayerVC)
    {
        
        [self.audioPlayerVC stopPlayerAndRemoveView];
        self.audioPlayerVC =  nil;
        
    }

}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:AudioPlayerDidChangeAudioFileNotification
                                               object:self.audioPlayerVC.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:AudioPlayerDidChangeOutputDeviceNotification
                                               object:self.audioPlayerVC.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:AudioPlayerDidChangePlayStateNotification
                                               object:self.audioPlayerVC.player];
}
//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    AudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    AudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    AudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}



//------------------------------------------------------------------------------
#pragma mark - VideoSyncControllerDelegate methods
//------------------------------------------------------------------------------


- (void) SyncController:(id) controller DidChangeState:(NSUInteger) state
{
    //NSLog(@"ViewController- VideoSyncControllerDelegate: %lu", (unsigned long)state);
    if (state == AudioSyncCrtlSyncTimelineAvailable) {
        
        if (![self.audioPlayerVC.player isPlaying])
        {
            [self.audioPlayerVC.player play];
        }
    }
    
//    if (state == VideoSyncCrtlSynchronising) [HUD showUIBlockingIndicatorWithText:@"Synchronising with your TV ..."];
//    
//
    
}

//------------------------------------------------------------------------------

- (void) SyncController:(AudioSyncController*) controller
           ReSyncStatus:(NSUInteger) status
                 Jitter:(NSTimeInterval) jitter
              WithError:(SyncControllerError*) erro
{
     if ((status == AudioSyncCrtlSynchronising) && (jitter < self.audSyncController.reSyncJitterThreshold)) [HUD hideUIBlockingIndicator];
}


//------------------------------------------------------------------------------
#pragma mark - AudioPlayerVCDelegate methods
//------------------------------------------------------------------------------

- (void) DidUpdateCurrentMediaTime:(float) timeInMs{
    
    
//    float progr=0;
//    // NSString* str = [NSString stringWithFormat:@"%.2f s", timeInMs];
//    
//    if (self.audioPlayerVC.player.duration > 0)
//    {
//        progr= timeInMs/ (self.audioPlayerVC.player.duration*1000);
//        NSLog(@"AudioPlayerVCDelegate DidUpdateCurrentMediaTime: duration =%f, currentTime=%f progress = %f", self.audioPlayerVC.player.duration, timeInMs,progr);
//       
//        
//    }
    
}

//------------------------------------------------------------------------------


@end
