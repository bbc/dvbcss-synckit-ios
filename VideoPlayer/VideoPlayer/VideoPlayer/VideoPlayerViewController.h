//
//  VideoPlayerViewController.h
//
//  Created by Rajiv Ramdhany on 10/06/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoPlayerView.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, VideoPlayerState)
{
    /**
     *  Video player in initialised state
     */
    VideoPlayerStateInitalised,
    /**
     *  End of video asset reached
     */
    VideoPlayerStateEndOfVideo,
    /**
     *  Video player in paused state
     */
    VideoPlayerStatePaused,
    /**
     *  Video player in playing state
     */
    VideoPlayerStatePlaying,
    /**
     *  Video player ready to play
     */
    VideoPlayerStateReadyToPlay,
    /**
     *  Video player in seeking state
     */
    VideoPlayerStateSeeking,
    /**
     *  Video player in unknown state
     */
    VideoPlayerStateUnknown,
};



//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 Notification that occurs whenever the VideoPlayer changes its `AVAsset` property. Check the new value using the VideoPlayer's `AVAsset` property.
 */
FOUNDATION_EXPORT NSString * const VideoPlayerDidChangeAVAssetNotification;

/**
 Notification that occurs whenever the VideoPlayer changes its component's play state. Check the new value using the VideoPlayer's `isPlaying` property.
 */
FOUNDATION_EXPORT NSString * const VideoPlayerDidChangePlayStateNotification;

/**
 Notification that occurs whenever the VideoPlayer has reached the end of a file and its `shouldLoop` property has been set to NO.
 */
FOUNDATION_EXPORT NSString * const VideoPlayerDidReachEndOfFileNotification;

/**
 Notification that occurs whenever the VideoPlayer performs a seek via the `seekToFrame` method or `setCurrentTime:` property setter. Check the new `currentTime` or `frameIndex` value using the VideoPlayer's `currentTime` or `frameIndex` property, respectively.
 */
FOUNDATION_EXPORT NSString * const VideoPlayerDidSeekNotification;

/**
 Notification that occurs after an observer has registered for current time of playback progress
 */
FOUNDATION_EXPORT NSString * const VideoPlayerCurrentTimeNotification;

/**
 Notification that occurs after an observer has registered for duration of playback video
 */
FOUNDATION_EXPORT NSString * const VideoPlayerDurationNotification;

/**
 Notification that occurs after an observer has registered for duration of playback video
 */
FOUNDATION_EXPORT NSString * const VideoPlayerLoadedTimeRangesNotification;

//------------------------------------------------------------------------------
#pragma mark - VideoPlayerDelegate
//------------------------------------------------------------------------------

/**
 * The VideoPlayerDelegate provides event callbacks for the VideoPlayer. VideoPlayerDelegate provides a small set of delegate methods in favor of notifications to allow multiple receivers of the VideoPlayer event callbacks since only one player is typically used in an application.  @warning These callbacks don't necessarily occur on the main thread so make sure you wrap any UI code in a GCD block:
 * @code dispatch_async(dispatch_get_main_queue(), ^{ // Update UI });
 */
@protocol VideoPlayerDelegate <NSObject>

@optional

//------------------------------------------------------------------------------

/**
 *  Callback triggered by this component to notify delegate about the state of the AVPlayer e.g. loading and
 *  priming its buffers for video playback, seeking, paused, reached end of file.
 *
 *  @param videoplayer the AVPlayer instance whose state is being reported
 *  @param state       a state from the VideoPlayerState enumeration
 */
-(void) VideoPlayer:(VideoPlayerView *) videoplayer
              State:(VideoPlayerState) state;

//------------------------------------------------------------------------------

/**
 *  Callback to inform delegate about current play time. This is called every 250 milliseconds.
 *
 *  @param videoplayer AVPlayer instance
 *  @param time        current time in the form of a CMTime
 */
- (void)VideoPlayer:(VideoPlayerView *) videoplayer
    updatedPosition:(NSTimeInterval) time;

//------------------------------------------------------------------------------

/**
 *  Callback to inform delegate that the video player has reached the end of file
 *
 *  @param videoplayer AVPlayer instance
 *  @param videoAsset  video item
 */
- (void)VideoPlayer:(VideoPlayerView *)videoplayer
reachedEndOfVideoFile:(AVPlayerItem *) videoAsset;

//------------------------------------------------------------------------------


/**
 *  Callback to inform that duration information is available. Duration is given in seconds.
 *
 *  @param videoplayer AVPlayer instance playing the video
 *  @param duration    duration in seconds.
 */
- (void) VideoPlayer:(VideoPlayerView *)videoplayer
   DurationAvailable:(NSTimeInterval) duration;

//------------------------------------------------------------------------------

/**
 *  Callback to inform that track information in the asset loaded for playback is available.
 *
 *  @param videoplayer AVPlayer instance playing the video
 *  @param track    duration in seconds.
 */
- (void) VideoPlayer:(VideoPlayerView *)videoplayer
   TrackInfoAvailable:(NSArray<AVPlayerItemTrack *>*) tracks;

//------------------------------------------------------------------------------

/**
 *  Callback to inform that loaded video time ranges are available. This can be used to calculate current playable duration
 *
 *  @param videoplayer AVPlayer instance playing the video
 *  @param ranges      A list of loaded time ranges.
 */
- (void) VideoPlayer:(VideoPlayerView *)videoplayer
   LoadedTimeRanges:(NSArray*) ranges;


//------------------------------------------------------------------------------

@end



//------------------------------------------------------------------------------
#pragma mark - VideoPlayerViewController
//------------------------------------------------------------------------------


/**
 *  The  VideoPlayerViewController is a UIViewController sub-class that embeds an AVPlayer object within a provided UIView. It  primes the AVPlayer with a video asset to play. It also allows the offset of the audio and video tracks to be adjusted with regards to the asset's timeline.
    
     This class also contains the heuristics to allow the video player to catch-up to a specified position
     using a strategy that minimises user experience disruption (e.g. by speeding up the play speed or doing a seek).
 */
@interface VideoPlayerViewController : UIViewController


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  The native video player this class uses to play videos.
 */
@property (readonly) VideoPlayerView* videoPlayer;

/**
 *  An offset in seconds by which the audio tyrack can be moved forward or back. This is used typically to callibrate the playback so that currentTime reports the time when the sound actually reaches the speakers.
 */
@property (nonatomic, assign) NSTimeInterval audioOffset;


/**
 *  An offset in seconds by which the audio tyrack can be moved forward or back. This is used typically to callibrate the playback so that currentTime reports the time when the sound actually reaches the speakers.
 */
@property (nonatomic, assign) NSTimeInterval videoOffset;


//------------------------------------------------------------------------------

/**
 A BOOL indicating whether the player should loop the file
 */
@property (nonatomic, assign) BOOL shouldLoop;

//------------------------------------------------------------------------------

/**
 An AudioPlayerState value representing the current internal playback and file state of the AudioPlayer instance.
 */
@property (nonatomic, readonly) VideoPlayerState state;

//------------------------------------------------------------------------------

/**
 * File or HTTP URL for companion video content e.g. H264/MP4 video file or  HLS VOD stream
 */
@property (nonatomic,strong) NSURL *videoURL;

//------------------------------------------------------------------------------

/**
 *  The VideoPlayerDelegate that will handle the audio player callbacks
 */
@property (nonatomic, strong) id<VideoPlayerDelegate> delegate;

//------------------------------------------------------------------------------

/**
 Provides the current offset in the video file as an NSTimeInterval (i.e. in seconds).  When setting this it will determine the correct frame offset and perform a seek to the new time offset.
 @warning Make sure the new current time offset is less than the `duration` or you will receive an invalid seek assertion. There are methods to cause the player to adapt its playback to move to a new position e.g.
     seekToTime and setRate.
 */
@property (nonatomic, readwrite) NSTimeInterval currentTime;

//------------------------------------------------------------------------------

/**
 * Provides the duration of the video asset loaded for playback. Note: this will only be populated after the
 * AVPlayer pipelines have been primed and the first video packets decoded.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

//------------------------------------------------------------------------------

/**
 *  Property specifying whether the video player is playing or not.
 */
@property (readonly) BOOL isPlaying;

//------------------------------------------------------------------------------

/**
 *  Property specifying whether the video player is playing or not.
 */
@property (nonatomic, readwrite) NSString* fillMode;

//------------------------------------------------------------------------------

/**
 *  rate of playback
 */
@property (nonatomic, readonly) float rate;


/**
 *  time ranges currently in buffer
 */
@property (nonatomic, readonly) NSArray<NSValue *> *loadedTimeRanges;

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

/**
 *  Initialise video player controller with a UIView in which to embed video player
 *
 *  @param parentView a UIView instance within which to embed video player
 *
 *  @return a VideoPlayerController instance
 */
- (id) initWithParentView:(UIView*) parentView;

//------------------------------------------------------------------------------

/**
 *  Initialise video player controller with a UIView in which to embed video player and register a delegate to receive callbacks.
 *
 *  @param parentView      UIView instance  within which to embed video player
 *  @param playerDelegate  a delegate object implementing the VideoPlayerDelegate
 *
 *  @return a VideoPlayerController instance
 */
- (id) initWithParentView:(UIView*) parentView
                    Delegate:(id<VideoPlayerDelegate>) playerDelegate;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------




/**
 *  Stops the VideoPlayerViewController and remove player view from parent view
 */
- (void) stopAndRemoveFromParentView;

//------------------------------------------------------------------------------

/**
 *  Pauses player
 */
- (void) pause;

//------------------------------------------------------------------------------

/**
 *  Start the video playback. If the video player was paused, it resumes from last paused position
 */
- (void) play;

//------------------------------------------------------------------------------

/**
 *  Sets the rate of playback in the AVPlayer.
 *  A value of 0.0 means pauses the video, while a value of 1.0 play at the natural rate of the current item.
 *  @param rate rate < 1.0 to slow the video playback 
 */
- (void) setRate: (float) rate;

//------------------------------------------------------------------------------

/**
 *  Synchronizes the playback rate and time of the current item with an external source. Essentially, the AVPlayer will resynchronise its media item to fulfill a new relationship between the media timeline and the host clock timeline as specified by a [itemTime, hostClockTime] pair. The rate specifies the speed at which the media time progresses w.r.t the host clock time.
 *
 *  @param rate          play speed
 *  @param itemTime      time position on media timeline in seconds
 *  @param hostClockTime time position in seconds on host clock. If the SystemClock mirrors the host clock, then it can be used as a time source for host clock time.
 */
- (void) setRate: (float)rate time:(Float64)itemTime atHostTime:(Float64)hostClockTime;

//------------------------------------------------------------------------------

/**
 *  Seek to time position in the media.
 *
 *  @param time time position on media timeline.
 */
- (void) seekToTime:(Float64) time;

//------------------------------------------------------------------------------

/**
 *  Subscribe an observer to receive playback time notifications (VideoPlayerCurrentTimeNotification) every 'periodMS' milliseconds
 *
 *  @param periodMs time interval in milliseconds, lowest value allowed is 100 ms.
 *  @param observer an observer object wishing to receive periodic notifications (of type ) from this video player
 */
- (BOOL) addPeriodicTime:(uint32_t) periodMs Observer: (id) observer;

//------------------------------------------------------------------------------

/**
 *  Unsubscribe an observing object from this player's notifications.
 *
 *  @param observerObj an observer object which has subscribed to receive periodic notifications (of type ) from this video player
 */
- (void) removePeriodicTimeObserver:(id) observer;

//------------------------------------------------------------------------------



@end




