//
//  AudioSyncController.h
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

#import <Foundation/Foundation.h>
#import <AudioPlayerEngine/EZAudio.h>

#import <ClockTimelines/ClockTimelines.h>

#import "SyncControllerError.h"
#import "SyncControllerDelegate.h"


@class AudioSyncController;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, AudioSyncControllerState)
{
    AudioSyncCrtlInitialised = 1,
    AudioSyncCrtlRunning,
    AudioSyncCrtlStopped,
    AudioSyncCrtlPaused,
    AudioSyncCrtlSynchronising,
    AudioSyncCrtlSyncTimelineUnavailable,
    AudioSyncCrtlSyncTimelineAvailable
};

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Timeline Synchroniser state change notification
 */
FOUNDATION_EXPORT NSString* const  kAudioSyncControllerResyncNotification;

//------------------------------------------------------------------------------
#pragma mark - AudioSyncController
//------------------------------------------------------------------------------

/**
 *  @brief A class to synchronise the playback of an audio player (AudioPlayer or AudioPlayerViewController)
 *  to a timeline representing the desired playback progress of the media object.
 *
 *  @discussion It needs a reference to an audio player (AudioPlayer or AudioPlayerViewController instance) and a CorrelatedClock
 *  representing the expected timeline of the audio object. This controller reads
 *  the actual and expected timeline positions of the audio item and determines the discrepancy
 *  between both readings. Based on the size of the discrepancy, it applies a simple strategy to adapt the
 *  playback of the audio player to achieve the expected playback position.
 *
 *  The resync process happens every 'syncInterval' seconds or when changes to the expectedTimeline
 *  are observed.
 *
 *  Ideas for future iterations of this component:
 *  1. Allow for different playback adaptation algorithms e.g. QoE-aware algo to be plugged in at configuration time
 *  2. Generalise component to synchronise media player timelines instead of actual players. Players will respond to changes in their timelines.
 */

@interface AudioSyncController : NSObject


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  A media timeline to synchronise to.
 */
@property (nonatomic, weak) CorrelatedClock *syncTimeline;

/**
 *  The expected timeline of the media object. Set using correlation timestamp supplied at initialisation time.
 */
@property (nonatomic, readonly) CorrelatedClock *mediaObjectTimeline;

/**
 *  An audio player to synchronise.
 */
@property (nonatomic, weak) AudioPlayer *audioPlayer;

/**
 *  Synchronisation interval
 */
@property (nonatomic) NSTimeInterval syncInterval;

/**
 *  This sync controller's state
 */
@property (nonatomic, readonly) AudioSyncControllerState state;

/**
 *  A delegate to report resynchronisation status.
 */
@property (nonatomic, weak) id<SyncControllerDelegate> delegate;

/**
 *  The jitter in media playback when resynchronising
 */
@property (nonatomic, readonly) NSTimeInterval syncJitter;


/**
 *  The threshold on the difference between expected and actual playback position, for which
 *  to trigger a resynchronisation. 
 */
@property (nonatomic, readonly) NSTimeInterval reSyncJitterThreshold;

/**
 *  A threshold for doing playback rate adaptation (increase/decrease speed) to allow the
 *  player to catchup/slow down. For a jitter value less than this threshold, a rate increase
 *  of 0.5 is applied to enable the player to be in sync.
 *  For a jitter value greater than this threshold, it is assumed that the discrepancy is too
 *  large for catchup by playback rate adjustment. A seek operation is performed on the player.
 */
@property (nonatomic) NSTimeInterval rateAdaptationJitterThreshold;




//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

- (instancetype) init NS_UNAVAILABLE;


/**
 *  Initialises an AudioSyncController with a audioplayer and a timeline to synchronise
 *  to.
 *
 *  @param audioplayer an AudioPlayer instance
 *  @param timeline    a CorrelatedClock instance modelling a particular timeline
 *
 *  @return initialised AudioSyncController instance
 */
- (instancetype) initWithAudioPlayer:(AudioPlayer*) audioplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation;

//------------------------------------------------------------------------------

/**
 *  Initialises an AudioSyncController with a audioplayer and a timeline to synchronise
 *  to.
 *
 *  @param audioplayer an AudioPlayer instance
 *  @param timeline    a CorrelatedClock instance modelling a particular timeline
 *  @param interval_secs resynchronisation interval in seconds (as a double value)
 *
 *  @return initialised AudioSyncController instance
 */
- (instancetype) initWithAudioPlayer:(AudioPlayer*) audioplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs;

//------------------------------------------------------------------------------

/**
 *  Initialises an AudioSyncController with a audioplayer and a timeline to synchronise
 *  to.
 *
 *  @param audioplayer an AudioPlayer instance
 *  @param timeline    a CorrelatedClock instance modelling a particular timeline
 *  @param interval_secs resynchronisation interval in seconds (as a double value)
 *  @param delegate      a delegate object (conforming to AudioSyncControllerDelegate protocol)
 *                       to receive callbacks
 *
 *  @return initialised AudioSyncController instance
 */
- (instancetype) initWithAudioPlayer:(AudioPlayer*) audioplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs
                             Delegate:(id<SyncControllerDelegate>) delegate;



//------------------------------------------------------------------------------
#pragma mark - Class Factory Methods
//------------------------------------------------------------------------------

/**
 *  Creates an instance of AudioSyncController initialised with an audio player and
 *  a synchronisation timelime (the timeline to synchronise to).
 *
 *  @param audioplayer   a AudioPlayer object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the 
                         audio object timeline
 *
 *  @return initialised AudioSyncController instance
 */
+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation;

//------------------------------------------------------------------------------

/**
 *  Creates an instance of AudioSyncController initialised with an audio player and
 *  a synchronisation timelime (the timeline to synchronise to) and a delegate to
 *  receive callbacks.
 *
 *  @param audioplayer   a AudioPlayer object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *  @param delegate      an object conforming to the AudioSyncControllerDelegate protocol
 *
 *  @return initialised AudioSyncController instance
 */
+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                   AndDelegate:(id<SyncControllerDelegate>) delegate ;

//------------------------------------------------------------------------------



/**
 *  Creates an instance of AudioSyncController initialised with an audio player and
 *  a synchronisation timelime (the timeline to synchronise to).  Resynchronisation of the
 *  player occurs every 'resync_interval' seconds.
 *
 *  @param audioplayer   a AudioPlayer object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *  @param resync_interval resynchronisation interval in seconds
 *
 *  @return initialised AudioSyncController instance
 */
+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                               AndSyncInterval:(NSTimeInterval) resync_interval;

//------------------------------------------------------------------------------

/**
 *  Creates an instance of AudioSyncController initialised with an audio player and
 *  a synchronisation timelime (the timeline to synchronise to).  Resynchronisation of the
 *  player occurs every 'resync_interval' seconds.
 *
 *  @param audioplayer   a AudioPlayer object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param correlation   a pair of timestamps mapping the synchronisation timeline to the
 audio object timeline
 *  @param resync_interval resynchronisation interval in seconds
 *  @param delegate      an object conforming to the AudioSyncControllerDelegate protocol
 *
 *  @return initialised AudioSyncController instance
 */
+ (instancetype) syncControllerWithAudioPlayer:(AudioPlayer*) audioplayer
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
