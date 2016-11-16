//
//  AudioSyncController.m
//  SyncController
//
//  Created by Rajiv Ramdhany on 16/05/2016.
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

#import "AudioSyncController.h"
#import <SimpleLogger/MWLogging.h>



//------------------------------------------------------------------------------
#pragma mark - Constants declaration
//------------------------------------------------------------------------------

// in seconds
NSTimeInterval const kAudioReSyncIntervalDefault             = 4.0;
NSTimeInterval const kAudioReSyncJitterThresholdDefault      = 0.005;
NSTimeInterval const kAudioRateAdaptJitterThresholdDefault   = 4.0;

// playback speed
NSTimeInterval const kAudioRateAdaptUpperThreshold       = 1.8;
NSTimeInterval const kAudioRateAdaptLowerThreshold       = 0.8;
NSTimeInterval const kAudioRateAdaptionPeriodThreshold   = 10.0;

//------------------------------------------------------------------------------
#pragma mark - Keys and Contexts for Key Value Observation
//------------------------------------------------------------------------------

static void *AudioSyncControllerContext         = &AudioSyncControllerContext;
static void *AudioObjectTimelineContext         = &AudioObjectTimelineContext;


//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

NSString* const  kAudioSyncControllerResyncNotification     =   @"AudioSyncControllerResyncNotification";



//------------------------------------------------------------------------------
#pragma mark - Interface extensions
//------------------------------------------------------------------------------
@interface AudioSyncController ()


//------------------------------------------------------------------------------
#pragma mark - access permissions redefinition
//------------------------------------------------------------------------------
@property (nonatomic, readwrite) NSTimeInterval syncJitter;
@property (nonatomic, readwrite) AudioSyncControllerState state;
@property (nonatomic, readwrite) NSTimeInterval reSyncJitterThreshold;

@end



//------------------------------------------------------------------------------
#pragma mark - AudioSyncController implementation
//------------------------------------------------------------------------------

@implementation AudioSyncController
{
    dispatch_source_t reSyncTimer;
    NSLock *reSyncStatusLock;
}


//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

- (instancetype) initWithAudioPlayer:(AudioPlayer*) audioplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
{
    
    return [self initWithAudioPlayer:audioplayer
                            Timeline:sync_timeline
                CorrelationTimestamp:correlation
                      ReSyncInterval:kAudioReSyncIntervalDefault
                            Delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype) initWithAudioPlayer:(AudioPlayer*) audioplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs
{
    
    return [self initWithAudioPlayer:audioplayer
                            Timeline:sync_timeline
                CorrelationTimestamp:correlation
                      ReSyncInterval:interval_secs
                            Delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype) initWithAudioPlayer:(AudioPlayer*) audioplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs
                            Delegate:(id<SyncControllerDelegate>) delegate
{
    self = [super init];
    
    if (self != nil) {
        
        _audioPlayer = audioplayer;
        _syncTimeline = sync_timeline;
        _syncInterval = interval_secs;
        _delegate = delegate;
        _reSyncJitterThreshold = kAudioReSyncJitterThresholdDefault * 1000; // milliseconds
        _rateAdaptationJitterThreshold = kAudioRateAdaptJitterThresholdDefault * 1000; // milliseconds
        
        
         // create the expected media object timeline (nanosecond precision)
        _mediaObjectTimeline = [[CorrelatedClock alloc] initWithParentClock:_syncTimeline
                                                                   TickRate:_kOneThousandMillion
                                                                Correlation:correlation];
        
        // register this controller to listen to changes to this clock (availability,
        [_mediaObjectTimeline addObserver:self context:AudioObjectTimelineContext ];
        
        _mediaObjectTimeline.available = _syncTimeline.available;
        
        _state = AudioSyncCrtlInitialised;
        
        reSyncStatusLock = [[NSLock alloc] init];
        
        reSyncTimer = nil;
        
        if (_mediaObjectTimeline.available) [self start];
        
    }
    return self;
}

//------------------------------------------------------------------------------

- (void)dealloc
{
    _mediaObjectTimeline = nil;
    MWLogDebug(@"AudioSyncController deallocated.");
    
}

//------------------------------------------------------------------------------
#pragma mark - Class Factory Methods
//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
{
    
    return  ([[AudioSyncController alloc] initWithAudioPlayer:audioplayer
                                                     Timeline:sync_timeline
                                         CorrelationTimestamp:correlation
                                               ReSyncInterval:kAudioReSyncIntervalDefault
                                                     Delegate:nil]);
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                   AndDelegate:(id<SyncControllerDelegate>) delegate
{
    return  ([[AudioSyncController alloc] initWithAudioPlayer:audioplayer
                                                     Timeline:sync_timeline
                                         CorrelationTimestamp:correlation
                                               ReSyncInterval:kAudioReSyncIntervalDefault
                                                     Delegate:delegate]);
    
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                               AndSyncInterval:(NSTimeInterval) resync_interval
{
    return  ([[AudioSyncController alloc] initWithAudioPlayer:audioplayer
                                                     Timeline:sync_timeline
                                         CorrelationTimestamp:correlation
                                               ReSyncInterval:kAudioReSyncIntervalDefault
                                                     Delegate:nil]);
}

//------------------------------------------------------------------------------

+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                  SyncInterval:(NSTimeInterval) resync_interval
                                   AndDelegate:(id<SyncControllerDelegate>) delegate
{
    return  ([[AudioSyncController alloc] initWithAudioPlayer:audioplayer
                                                     Timeline:sync_timeline
                                         CorrelationTimestamp:correlation
                                               ReSyncInterval:kAudioReSyncIntervalDefault
                                                     Delegate:delegate]);
    
}

//------------------------------------------------------------------------------
#pragma mark - setters
//------------------------------------------------------------------------------

- (void) setState:(AudioSyncControllerState)state
{
    
    _state = state;
    
    __weak AudioSyncController *weakSelf = self;
    
    // dispatch callbacks and notifications asynchronously
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_delegate) {
            [_delegate SyncController:self DidChangeState:state];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAudioSyncControllerResyncNotification object:weakSelf userInfo:@{kAudioSyncControllerResyncNotification: [NSNumber numberWithUnsignedInteger: _state]}];
        
    });
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------


- (void) start
{
    // run
    
    if (!reSyncTimer) {
        reSyncTimer = __CreateDispatchTimer__(5000*NSEC_PER_MSEC,
                                          1* NSEC_PER_MSEC,
                                          dispatch_get_main_queue(),
                                          ^{ [self ReSync]; });
        dispatch_resume(reSyncTimer);
        MWLogDebug(@"AudioSyncController(): reSync timer started.");
    }else
    {
        if (self.state == AudioSyncCrtlPaused)
            dispatch_resume(reSyncTimer);
    }
    self.state = AudioSyncCrtlRunning;
    MWLogDebug(@"AudioSyncController for media player object %@ started", _audioPlayer.audioFileURL);

}

//------------------------------------------------------------------------------


- (void) stop
{
    self.state = AudioSyncCrtlStopped;
    
    [self __cancelTimer__:reSyncTimer];

    self.delegate = nil;

    // unregister this object as an observer of the mediaObjectTimeline
    [_mediaObjectTimeline removeObserver:self Context:AudioObjectTimelineContext];
    
    MWLogDebug(@"AudioSyncController for media player object %@ stopped.", _audioPlayer.audioFile.url.absoluteString);
    self.audioPlayer = nil;
    
    _mediaObjectTimeline = nil;

}

//------------------------------------------------------------------------------

- (void)suspend
{
    if (reSyncTimer) {
        dispatch_suspend(reSyncTimer);
        
    }
    MWLogDebug(@"AudioSyncController for media player object %@ paused.", _audioPlayer.audioFileURL);
    
    self.state = AudioSyncCrtlPaused;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - KVO for WallClock and TVTimeline
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == AudioObjectTimelineContext) {
        
        
        if ([keyPath isEqualToString:kTickRateKey]) {
            
            
        }else if ([keyPath isEqualToString:kSpeedKey]) {
            
            NSLog(@"AudioSyncController: media object timeline speed changed.");
            
            // set the speed
            //            float oldSpeed = [[change objectForKey:@"old"] floatValue];
            //            float newSpeed = [[change objectForKey:@"new"] floatValue];
            
            // trigger a resync with speed == 0.0
            
            if (self.state == AudioSyncCrtlRunning) [self ReSync];
            
        }else if([keyPath isEqualToString:kCorrelationKey]) {
            NSLog(@"AudioSyncController: media object timeline correlation changed.");
            
            // trigger a resync
            if (self.state == AudioSyncCrtlRunning) [self ReSync];
            
            
            
            
        }else if ([keyPath isEqualToString:kAvailableKey]) {
            
            BOOL oldAvailable = [[change objectForKey:@"old"]boolValue];
            BOOL newAvailable = [[change objectForKey:@"new"]boolValue];
            
            NSString *msg = [NSString stringWithFormat:@"changed from %d to %d", oldAvailable, newAvailable];
            
            NSLog(@"AudioSyncController: media object timeline availability  %@", msg);
            
            // if available == true AND VideoPlayerSyncController is not sync'ing, start resync
            
            if ((newAvailable) && ((_state == AudioSyncCrtlInitialised) || (_state == AudioSyncCrtlSyncTimelineUnavailable)))
            {
                self.state = AudioSyncCrtlSyncTimelineAvailable;
                
                [self start];
            }else if ((!newAvailable) && ((_state == AudioSyncCrtlRunning) || (_state == AudioSyncCrtlSynchronising)))
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
    
    if (self.state != AudioSyncCrtlSynchronising){
        
        self.state = AudioSyncCrtlSynchronising;
        
        // determine sync jitter
        // sync jitter = expected timeline position - actual timeline position
        // We assume that both timelines are similar i.e. have same tickrate
        // and represent the media object's timeline.
        
        int64_t expectedTimelineticksNow    = [self.mediaObjectTimeline ticks];
        
        Float64 expectedAudioTimeNanos = [self.mediaObjectTimeline ticksToNanoSeconds:expectedTimelineticksNow];
        
        Float64 currentAudioTimeNanos = (self.audioPlayer.currentTime * _kOneThousandMillion);
        
        Float64 jitterMs = (expectedAudioTimeNanos - currentAudioTimeNanos) / 1000000;
        
        
        NSLog(@"AudioSyncController resync(): expected: %f ,current = %f", expectedAudioTimeNanos/1000000.0, currentAudioTimeNanos/1000000.0);
        
        if (_delegate) {
            [_delegate SyncController:self ReSyncStatus:_state Jitter:jitterMs WithError:nil];
        }
        
        NSLog(@"AudioSyncController resync(): jitter in ms: %f, audio duration: %f", jitterMs, _audioPlayer.duration);
        
        NSTimeInterval expectedAudioTimeMillis = expectedAudioTimeNanos / 1000000.0;
        NSTimeInterval durationMillis = _audioPlayer.duration * 1000;
        
        if ((fabs(jitterMs) > _reSyncJitterThreshold) &&
            (expectedAudioTimeMillis > 0.0) &&
            (expectedAudioTimeMillis < durationMillis))
        {
            
             NSLog(@"AudioSyncController resync(): seeking audio to ms: %f", expectedAudioTimeMillis);
            [self.audioPlayer seekToTime:expectedAudioTimeMillis];
        }
    } // end if (self.state != AudioSyncCrtlSynchronising)
    
    //        // release the lock
    //        [reSyncStatusLock unlock];
    //    }
    
    self.state = AudioSyncCrtlRunning;
    
}

//------------------------------------------------------------------------------

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
dispatch_source_t __CreateDispatchTimer__(uint64_t interval,
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



- (void) __cancelTimer__:(dispatch_source_t) timer
{
    if (timer) {
        dispatch_source_cancel(timer);
        // Remove this if you are on a Deployment Target of iOS6 or OSX 10.8 and above
        timer = nil;
    }
}

//------------------------------------------------------------------------------
@end
