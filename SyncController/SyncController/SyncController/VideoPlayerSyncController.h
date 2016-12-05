//
//  SyncController.h
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

#import <Foundation/Foundation.h>
#import <VideoPlayer/VideoPlayer.h>
#import <ClockTimelines/ClockTimelines.h>

#import "SyncControllerError.h"
#import "SyncControllerDelegate.h"


@class VideoPlayerSyncController;
//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, VideoSyncControllerState)
{
    VideoSyncCrtlInitialised = 1,
    VideoSyncCrtlRunning,
    VideoSyncCrtlStopped,
    VideoSyncCrtlPaused,
    VideoSyncCrtlSynchronising,
    VideoSyncCrtlSyncTimelineUnavailable,
    VideoSyncCrtlSyncTimelineAvailable
};

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Timeline Synchroniser state change notification
 */
FOUNDATION_EXPORT NSString* const  kVideoSyncControllerResyncNotification;


//------------------------------------------------------------------------------
#pragma mark - VideoPlayerSyncController
//------------------------------------------------------------------------------

/**
 *  @brief A class to synchronise the playback of a video player (VideoPlayerViewController)
 *  to a timeline representing the desired playback progress of the media object.
 *  
 *  @discussion It needs a reference to a video player (VideoPlayerViewController instance) and a CorrelatedClock
 *  representing the expected timeline of the video object. This controller reads
 *  the actual and expected timeline positions of the video item and determines the discrepancy
 *  between both readings. Based on the size of the discrepancy, it applies a simple strategy to adapt the
 *  playback of the video player to achieve the expected playback position.
 *
 *  The resync process happens every 'syncInterval' seconds or when changes to the expectedTimeline
 *  are observed.
 *
 *  Ideas for future iterations of this component:
 *  1. Allow for different playback adaptation algorithms e.g. QoE-aware algo to be plugged in at configuration time
 *  2. Generalise component to synchronise media player timelines instead of actual players. Players will respond to changes in their timelines.
 */
@interface VideoPlayerSyncController : NSObject


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
 *  A video player to synchronise.
 */
@property (nonatomic, weak) VideoPlayerViewController *videoPlayer;

/**
 *  Synchronisation interval
 */
@property (nonatomic) NSTimeInterval syncInterval;

/**
 *  This sync controller's state
 */
@property (nonatomic, readonly) VideoSyncControllerState state;

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
 *  to trigger a resynchronisation. E.g. for values lower than a video frame duration, no
 *  resync needs to be done.
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
 *  Initialises a VideoPlayerSyncController with a videoplayer and a timeline to synchronise
 *  to.
 *
 *  @param videoplayer a VideoPlayerViewController instance
 *  @param timeline    a CorrelatedClock instance modelling a particular timeline
 *
 *  @return initialised VideoPlayerSyncController instance
 */
- (instancetype) initWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation;

//------------------------------------------------------------------------------

/**
 *  Initialises a VideoPlayerSyncController with a videoplayer and a timeline to synchronise
 *  to.
 *
 *  @param videoplayer   a VideoPlayerViewController instance
 *  @param timeline      a CorrelatedClock instance modelling a particular timeline
 *  @param interval_secs resynchronisation interval in seconds (as a double value)
 *
 *  @return initialised VideoPlayerSyncController instance
 */
- (instancetype) initWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                            Timeline:(CorrelatedClock*) sync_timeline
                CorrelationTimestamp:(Correlation *) correlation
                      ReSyncInterval:(NSTimeInterval) interval_secs;

//------------------------------------------------------------------------------

/**
 *  Initialises a VideoPlayerSyncController with a videoplayer and a timeline to synchronise
 *  to.
 *
 *  @param videoplayer   a VideoPlayerViewController instance
 *  @param timeline      a CorrelatedClock instance modelling a particular timeline
 *  @param interval_secs resynchronisation interval in seconds (as a double value)
 *  @param delegate      a delegate object (conforming to VideoSyncControllerDelegate protocol) 
 *                       to receive callbacks
 *
 *  @return initialised VideoPlayerSyncController instance
 */
- (instancetype) initWithVideoPlayer :(VideoPlayerViewController*) videoplayer
                             Timeline:(CorrelatedClock*) sync_timeline
                 CorrelationTimestamp:(Correlation *) correlation
                       ReSyncInterval:(NSTimeInterval) interval_secs
                             Delegate:(id<SyncControllerDelegate>) delegate;



//------------------------------------------------------------------------------
#pragma mark - Class Factory Methods
//------------------------------------------------------------------------------

/**
 *  Creates an instance of VideoPlayerSyncController initialised with a video player and
 *  a synchronisation timelime (the timeline to synchronise to).
 *
 *  @param videoplayer   a VideoPlayerViewController object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *
 *  @return initialised VideoPlayerSyncController instance
 */
+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation;

//------------------------------------------------------------------------------

/**
 *  Creates an instance of VideoPlayerSyncController initialised with a video player,
 *  a synchronisation timelime (the timeline to synchronise to) and a delegate to
 *  receive callbacks.
 *
 *  @param videoplayer   a VideoPlayerViewController object
 *  @param sync_timeline a CorrelatedClock object representing a synchronisation timeline
 *  @param delegate      an object conforming to the VideoSyncControllerDelegate protocol
 *
 *  @return initialised VideoPlayerSyncController instance
 */
+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                                   AndDelegate:(id<SyncControllerDelegate>) delegate ;

//------------------------------------------------------------------------------

/**
 *  Creates an instance of VideoPlayerSyncController initialised with a video player and
 *  a synchronisation timelime (the timeline to synchronise to). Resynchronisation of the
 *  player occurs every 'resync_interval' seconds.
 *
 *  @param videoplayer     a VideoPlayerViewController object
 *  @param sync_timeline   a CorrelatedClock object representing a synchronisation timeline
 *  @param resync_interval resynchronisation interval in seconds
 *
 *  @return initialised VideoPlayerSyncController instance
 */
+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
                                  SyncTimeline:(CorrelatedClock*) sync_timeline
                          CorrelationTimestamp:(Correlation *) correlation
                               AndSyncInterval:(NSTimeInterval) resync_interval;

//------------------------------------------------------------------------------

/**
 *   Creates an instance of VideoPlayerSyncController initialised with a video player,
 *  a synchronisation timelime (the timeline to synchronise to) and a delegate to
 *  receive callbacks. Resynchronisation of the player occurs every 'resync_interval' seconds.
 *
 *  @param videoplayer     a VideoPlayerViewController object
 *  @param sync_timeline   a CorrelatedClock object representing a synchronisation timeline
 *  @param resync_interval resynchronisation interval in seconds
 *  @param delegate        an object conforming to the VideoSyncControllerDelegate protocol
 *
 *  @return initialised VideoPlayerSyncController instance
 */
+ (instancetype) syncControllerWithVideoPlayer:(VideoPlayerViewController*) videoplayer
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
