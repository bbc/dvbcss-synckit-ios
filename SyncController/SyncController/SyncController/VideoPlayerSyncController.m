//
//  SyncController.m
//  VideoSyncController
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

#import "VideoPlayerSyncController.h"
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <SimpleLogger/MWLogging.h>


//------------------------------------------------------------------------------
#pragma mark - Constants declaration
//------------------------------------------------------------------------------

// in seconds
NSTimeInterval const kReSyncIntervalDefault             = 4.0;
NSTimeInterval const kReSyncJitterThresholdDefault      = 0.02;
NSTimeInterval const kRateAdaptJitterThresholdDefault   = 4.0;

// playback speed
NSTimeInterval const kRateAdaptUpperThreshold       = 1.8;
NSTimeInterval const kRateAdaptLowerThreshold       = 0.8;
NSTimeInterval const kRateAdaptionPeriodThreshold   = 10.0;

//------------------------------------------------------------------------------
#pragma mark - Keys and Contexts for Key Value Observation
//------------------------------------------------------------------------------

static void *SyncControllerContext          = &SyncControllerContext;
static void *MediaObjectTimelineContext     = &MediaObjectTimelineContext;
//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

NSString* const  kVideoSyncControllerResyncNotification     =   @"VideoSyncControllerResyncNotification";

//------------------------------------------------------------------------------
#pragma mark - Interface extensions
//------------------------------------------------------------------------------

@interface VideoPlayerSyncController ()

@property (nonatomic, readwrite) NSTimeInterval syncJitter;
@property (nonatomic, readwrite) VideoSyncControllerState state;
@property (nonatomic, readwrite) NSTimeInterval reSyncJitterThreshold;

@property (nonatomic, readwrite) BOOL httpStreaming;

@end


//------------------------------------------------------------------------------
#pragma mark - VideoPlayerSyncController implementation
//------------------------------------------------------------------------------

@implementation VideoPlayerSyncController
{
    dispatch_source_t reSyncTimer;
    NSLock *reSyncStatusLock;
    
}

//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

- (instancetype) initWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
{
    
    return [self initWithVideoPlayer:videoplayer
                            Timeline:sync_timeline
            CorrelationTimestamp:correlation
                      ReSyncInterval:kReSyncIntervalDefault
                            Delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype) initWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs
{
    
    return [self initWithVideoPlayer:videoplayer
                            Timeline:sync_timeline
                CorrelationTimestamp:correlation
                      ReSyncInterval:interval_secs
                            Delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype) initWithVideoPlayer :(VideoPlayerViewController*) videoplayer
                             Timeline:(CorrelatedClock*) sync_timeline
                 CorrelationTimestamp:(Correlation *) correlation
                       ReSyncInterval:(NSTimeInterval) interval_secs
                             Delegate:(id<SyncControllerDelegate>) delegate
{
    self = [super init];
    
    if (self != nil) {
        
        _videoPlayer = videoplayer;
        _syncTimeline = sync_timeline;
        _syncInterval = interval_secs;
        _delegate = delegate;
        _reSyncJitterThreshold = kReSyncJitterThresholdDefault * 1000; // milliseconds
        _rateAdaptationJitterThreshold = kRateAdaptJitterThresholdDefault * 1000; // milliseconds
        
        _httpStreaming = [self isPlayingStream];
        
        // create the expected media object timeline
        _mediaObjectTimeline = [[CorrelatedClock alloc] initWithParentClock:_syncTimeline
                                                                     TickRate:_kOneThousandMillion
                                                                  Correlation:correlation];
        
        // register this controller to listen to changes to this clock (availability,
        [_mediaObjectTimeline addObserver:self context:MediaObjectTimelineContext ];
        
       
            
        _state = VideoSyncCrtlInitialised;
        
        reSyncStatusLock = [[NSLock alloc] init];
        
        reSyncTimer = nil;
         _mediaObjectTimeline.available = _syncTimeline.available;
        if (_mediaObjectTimeline.available) [self start];
        
        
    }
    return self;
}

//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - Class Factory Methods
//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
{
    
    return  ([[VideoPlayerSyncController alloc] initWithVideoPlayer:videoplayer
                                                           Timeline:sync_timeline
                                               CorrelationTimestamp:correlation
                                                     ReSyncInterval:kReSyncIntervalDefault
                                                           Delegate:nil]);
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                   AndDelegate:(id<SyncControllerDelegate>) delegate
{
    return  ([[VideoPlayerSyncController alloc] initWithVideoPlayer:videoplayer
                                                           Timeline:sync_timeline
                                               CorrelationTimestamp:correlation
                                                     ReSyncInterval:kReSyncIntervalDefault
                                                           Delegate:delegate]);
    
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                               AndSyncInterval:(NSTimeInterval) resync_interval
{
    return  ([[VideoPlayerSyncController alloc] initWithVideoPlayer:videoplayer
                                                           Timeline:sync_timeline
                                               CorrelationTimestamp:correlation
                                                     ReSyncInterval:resync_interval
                                                           Delegate:nil]);
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                  SyncInterval:(NSTimeInterval) resync_interval
                                   AndDelegate:(id<SyncControllerDelegate>) delegate
{
    return  ([[VideoPlayerSyncController alloc] initWithVideoPlayer:videoplayer
                                                           Timeline:sync_timeline
                                               CorrelationTimestamp:correlation
                                                     ReSyncInterval:resync_interval
                                                           Delegate:delegate]);

}

//------------------------------------------------------------------------------
#pragma mark - setters
//------------------------------------------------------------------------------

- (void) setState:(VideoSyncControllerState)state
{
    
    _state = state;
    
    __weak VideoPlayerSyncController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_delegate) {
            [_delegate SyncController:self DidChangeState:state];
        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoSyncControllerResyncNotification object:weakSelf userInfo:@{kVideoSyncControllerResyncNotification: [NSNumber numberWithUnsignedInteger: _state]}];
       
    });
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------


- (void) start
{
    // run
    
    if (!reSyncTimer) {
        reSyncTimer = CreateDispatchTimer(5000*NSEC_PER_MSEC,
                                          1* NSEC_PER_MSEC,
                                          dispatch_get_main_queue(),
                                          ^{ [self ReSync]; });        dispatch_resume(reSyncTimer);
        MWLogDebug(@"VideoPlayerSyncController.start(): reSync timer started.");
    }else
    {
        if (self.state == VideoSyncCrtlPaused)
        {
            dispatch_resume(reSyncTimer);
            MWLogDebug(@"VideoPlayerSyncController for player %@ started", [_videoPlayer.videoURL absoluteString]);
        }
        
    }
    self.state = VideoSyncCrtlRunning;
    
}

//------------------------------------------------------------------------------


- (void) stop
{
    self.state = VideoSyncCrtlStopped;
    
    [self cancelTimer:reSyncTimer];
    
    
   
    self.delegate = nil;
    
    // unregister this object as an observer of the mediaObjectTimeline 
    [_mediaObjectTimeline removeObserver:self Context:MediaObjectTimelineContext];
     MWLogDebug(@"VideoPlayerSyncController for player %@ stopped.", [_videoPlayer.videoURL absoluteString]);
    self.videoPlayer = nil;
    
    _mediaObjectTimeline = nil;
}


//------------------------------------------------------------------------------

- (void)dealloc
{
    
    MWLogDebug(@"VideoPlayerSyncController deallocated.");
    
}

//------------------------------------------------------------------------------
- (void)suspend
{
    if (reSyncTimer) {
        dispatch_suspend(reSyncTimer);
        
    }
    MWLogDebug(@"VideoPlayerSyncController for player %@ paused.", [_videoPlayer.videoURL absoluteString]);
    self.state = VideoSyncCrtlPaused;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - KVO for WallClock and TVTimeline
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == MediaObjectTimelineContext) {
       
        
        if ([keyPath isEqualToString:kTickRateKey]) {
            
            
        }else if ([keyPath isEqualToString:kSpeedKey]) {
            
            NSLog(@"VideoPlayerSyncController: media object timeline speed changed.");
            
            // set the speed
//            float oldSpeed = [[change objectForKey:@"old"] floatValue];
//            float newSpeed = [[change objectForKey:@"new"] floatValue];
            
            // trigger a resync with speed == 0.0
            
           [self ReSync];
            
        }else if([keyPath isEqualToString:kCorrelationKey]) {
            NSLog(@"VideoPlayerSyncController: media object timeline correlation changed.");
            
            // trigger a resync
            if (self.state == VideoSyncCrtlRunning) [self ReSync];
            
            
            
            
        }else if ([keyPath isEqualToString:kAvailableKey]) {
            
            BOOL oldAvailable = [[change objectForKey:@"old"]boolValue];
            BOOL newAvailable = [[change objectForKey:@"new"]boolValue];
            
            NSString *msg = [NSString stringWithFormat:@"changed from %d to %d", oldAvailable, newAvailable];
            
            NSLog(@"VideoPlayerSyncController: media object timeline availability  %@", msg);
            
            // if available == true AND VideoPlayerSyncController is not sync'ing, start resync
            
            if ((newAvailable) && ((_state == VideoSyncCrtlInitialised) || (_state == VideoSyncCrtlSyncTimelineUnavailable)))
            {
                self.state = VideoSyncCrtlSyncTimelineAvailable;
                
                [self start];
            }else if ((!newAvailable) && ((_state == VideoSyncCrtlRunning) || (_state == VideoSyncCrtlSynchronising)))
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
 *  Resychronises the video player to the sync timeline. This method is called
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
    
        if (self.state != VideoSyncCrtlSynchronising){
            
            self.state = VideoSyncCrtlSynchronising;
        
            // determine sync jitter
            // sync jitter = expected timeline position - actual timeline position
            // We assume that both timelines are similar i.e. have same tickrate
            // and represent the media object's timeline.
            
            int64_t expectedTimelineticksNow    = [self.mediaObjectTimeline ticks];
            
            Float64 expectedVideoTimeNanos = [self.mediaObjectTimeline ticksToNanoSeconds:expectedTimelineticksNow];
            
            
            Float64 expectedVideoHostTimeNanos = [self.mediaObjectTimeline computeTimeNanos:expectedTimelineticksNow];
            
            
            Float64 currentVideoTimeNanos = (self.videoPlayer.currentTime * _kOneThousandMillion);
            
            Float64 jitterMs = (expectedVideoTimeNanos - currentVideoTimeNanos) / 1000000;
            
            
            NSLog(@"VideoPlayerSyncController resync(): expected: %f ,current = %f", expectedVideoTimeNanos, currentVideoTimeNanos);
            
            if (_delegate) {
                [_delegate SyncController:self ReSyncStatus:_state Jitter:jitterMs WithError:nil];
            }
            
            NSLog(@"VideoPlayerSyncController resync(): jitter in ms: %f", jitterMs);
            
            if ((fabs(jitterMs) > _reSyncJitterThreshold) || (_mediaObjectTimeline.speed != self.videoPlayer.rate))
            {
                if (!_httpStreaming){
                    [self.videoPlayer setRate:_mediaObjectTimeline.speed
                                         time: expectedVideoTimeNanos
                                   atHostTime:expectedVideoHostTimeNanos];
                }else
                {
                    
                    
                    [self.videoPlayer seekToTime:([self.mediaObjectTimeline time]+0.15)];
                }
            }
        } // end if (self.state != VideoSyncCrtlSynchronising)
        
//        // release the lock
//        [reSyncStatusLock unlock];
//    }
    
    self.state = VideoSyncCrtlRunning;
 
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


- (void) cancelTimer:(dispatch_source_t) timer
{
    if (timer) {
        dispatch_source_cancel(timer);
        // Remove this if you are on a Deployment Target of iOS6 or OSX 10.8 and above
        timer = nil;
    }
}


- (BOOL) isPlayingStream
{
    if (self.videoPlayer.videoURL){
        return (([self.videoPlayer.videoURL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame) ||
            ([self.videoPlayer.videoURL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame));
    }else
        return NO;

}

//------------------------------------------------------------------------------


@end
