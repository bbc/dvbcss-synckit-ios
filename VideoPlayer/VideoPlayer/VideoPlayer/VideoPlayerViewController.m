//
//  VideoPlayerViewController.m
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

#import <AVFoundation/AVFoundation.h>
#include <mach/mach_time.h>
#import "VideoPlayerViewController.h"
#import "VideoPlayerView.h"
#import "AddDelayAudioTapProcessor.h"
#import "VideoPlayerError.h"

//------------------------------------------------------------------------------
#pragma mark - video playback performance constants in seconds
//------------------------------------------------------------------------------

// audio and video callibration constants in milliseconds
NSTimeInterval const kCallibratedVideoOffset = -15.0;
NSTimeInterval const kCallibratedAudioOffset = 64;

// seek imprecision tolerance in seconds
NSTimeInterval const kSeekTolerance = 20e-3;

// Current Media Time notification interval in seconds
NSTimeInterval const kCurrentTimeNotificationInterval = 100e-3; // 100 milliseconds


//------------------------------------------------------------------------------
#pragma mark - Keys and Contexts for Key Value Observation
//------------------------------------------------------------------------------

/*Assets Keys*/
NSString* const kPlayableKey            =   @"playable";
NSString* const kTracksKey              =   @"tracks";
NSString* const kDuration               =   @"duration";

/*AVPlayerItem keys*/
NSString* const kStatusKey              =   @"status";
NSString* const kCurrentItemKey         =   @"currentItem";
NSString * const kLoadedTimeRangesKey   =   @"loadedTimeRanges";
//------------------------------------------------------------------------------

/**
 *  Contexts for KVO
 */
static void *VideoPlayerCurrentItemObservationContext   = &VideoPlayerCurrentItemObservationContext;
static void *VideoPlayerStatusObservationContext        = &VideoPlayerStatusObservationContext;
static void *VideoPlayerTracksObservationContext        = &VideoPlayerTracksObservationContext;
static void *VideoPlayerBufferingObservationContext     = &VideoPlayerBufferingObservationContext;


//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

NSString * const VideoPlayerDidChangeAVAssetNotification    = @"VideoPlayerDidChangeAVAssetNotification";
NSString * const VideoPlayerDidChangePlayStateNotification  = @"VideoPlayerDidChangePlayStateNotification";
NSString * const VideoPlayerDidReachEndOfFileNotification   = @"VideoPlayerDidReachEndOfFileNotification";
NSString * const VideoPlayerCurrentTimeNotification         = @"VideoPlayerCurrentTimeNotification";
NSString * const VideoPlayerDurationNotification            =  @"VideoPlayerDurationNotification";
NSString * const VideoPlayerLoadedTimeRangesNotification    = @"VideoPlayerLoadedTimeRangesNotification";
NSString * const AVPlayerCurrentTimeNotif                   = @"AVPlayerCurrentTimeNotification";


//------------------------------------------------------------------------------
#pragma mark - Private Classes
//------------------------------------------------------------------------------

/**
 * private class for observers
 */
@interface AVPlayerControllerObserver : NSObject

/**
 *  observer
 */
@property (nonatomic, readwrite) id observingObject;

/**
 *  an AVPlayer time observer (returned by observer registration)
 */
@property (nonatomic, readwrite) id avPlayerTimeObserver;

/**
 *  interval for receiving time observations
 */
@property (nonatomic, readwrite) uint32_t periodMs;

@end

//------------------------------------------------------------------------------
@implementation AVPlayerControllerObserver
{
    
}


@end
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - VideoPlayerViewController (Interface Extension)
//------------------------------------------------------------------------------

@interface VideoPlayerViewController ()
{
    /**
     *  Seek inaccuracy tolerance
     */
    CMTime seekTolerance;
   
 
}

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  Accessor permission redefinition
 */
@property (nonatomic, readwrite) VideoPlayerView* videoPlayer;
@property (nonatomic, readwrite) VideoPlayerState state;
@property (nonatomic, readwrite) BOOL isPlaying;
@property (nonatomic, readwrite) NSTimeInterval duration;
@property (nonatomic, readwrite) float rate;
@property (nonatomic, readwrite) NSArray<NSValue *> *loadedTimeRanges;

//------------------------------------------------------------------------------

/**
 *  A reference to an AVPlayerItem object representing the asset the video player is playing
 */
@property (nonatomic) AVPlayerItem *playerItem;

//------------------------------------------------------------------------------

/**
 *  An AVPlayer time observer, used to observing time progress on player
 */
@property (nonatomic) id playerObserver;

/**
 *  Audio Tap Processor
 */
@property (nonatomic) AddDelayAudioTapProcessor *audioTapProcessor;

//------------------------------------------------------------------------------

/**
 *  Prepare to play a video file. This will load and prime the video processing pipeline.
  *
 *  @param asset         AVURLAsset object representing the video file
 *  @param requestedKeys keys to observe (KVO pattern)
 */
- (BOOL) prepareToPlayAsset:(AVURLAsset *)asset
                   withKeys:(NSArray *)requestedKeys
                      Error:(NSError**) error;

//------------------------------------------------------------------------------

/**
 *  Prepare to play a video stream (only HLS supported on iOS). This will load and prime the video processing pipeline.
 *
 *  @param streamURL the HLS stream URL
 */
- (BOOL) prepareToPlayHLSVideoStream:(NSURL *)streamURL
                            withKeys:(NSArray *)requestedKeys
                               Error:(NSError**) error;

//------------------------------------------------------------------------------

@end


//------------------------------------------------------------------------------
#pragma mark - VideoPlayerViewController implementation
//------------------------------------------------------------------------------


@implementation VideoPlayerViewController
{
    NSNotificationCenter*   notificationCenter;
    NSMutableArray*         timeObserversArray;
    UIView*                 parentView;
    
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle methods: Initialization, Dealloc, etc
//------------------------------------------------------------------------------


- (id) init
{
    return [self initWithParentView:self.view Delegate:nil];

}

//------------------------------------------------------------------------------

- (id) initWithParentView:(UIView*) pView
{
    
    return [self initWithParentView:pView Delegate:nil];
}


//------------------------------------------------------------------------------

- (id) initWithParentView:(UIView*) pView
                 Delegate:(id<VideoPlayerDelegate>) playerDelegate
{
    
    if ((self = [super init])) {
        
        self.videoPlayer =  [[VideoPlayerView alloc] initWithParentView:pView];
        parentView = pView;
        
        [self.videoPlayer setAutoresizingMask:UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth];
        [self.videoPlayer setVideoFillMode:AVLayerVideoGravityResizeAspect];
        self.view = self.videoPlayer;
        
        // we want a seek error tolerance of about a video frame
        seekTolerance = CMTimeMake(20, 1000);
        
        notificationCenter = [NSNotificationCenter defaultCenter];
        
        self.state = VideoPlayerStateInitalised;
        
        self.delegate = playerDelegate;
        
        self.isPlaying = NO;
        
        _audioOffset = kCallibratedAudioOffset;
        
    }
    return self;
    
    
}


//------------------------------------------------------------------------------


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)dealloc {
    
    NSLog(@"VideoPlayerViewController: disposing memory resources.");
    
}



//------------------------------------------------------------------------------
#pragma mark - UIView Lifecycle methods
//------------------------------------------------------------------------------


- (void) viewDidLoad
{
    [super viewDidLoad];

    
}

//------------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated
{
    
}


//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (NSTimeInterval) currentTime
{
    //CMTime ctime = [self.videoPlayer.player currentTime];
    
        return  CMTimeGetSeconds([self.videoPlayer.player currentTime]);
//    else
//        return (CMTimeGetSeconds([self.videoPlayer.player currentTime]) + (kCallibratedVideoOffset/1000));
}

//------------------------------------------------------------------------------

//- (NSTimeInterval) duration
//{
//    NSValue *range = self.videoPlayer.player.currentItem.loadedTimeRanges.firstObject;
//    CMTime ctime;
//    
//    if (range != nil){
//        ctime = CMTimeRangeGetEnd(range.CMTimeRangeValue);
//        return ctime.value/ctime.timescale;
//    }else
//        return -1;
//    
//}

//------------------------------------------------------------------------------
- (float) rate
{
    
    return _videoPlayer.player.rate;
    
}


//------------------------------------------------------------------------------


- (AddDelayAudioTapProcessor *)audioTapProcessor
{
    // create an audio tap processor for the asset's audio track
    if (!_audioTapProcessor)
    {
        AVAssetTrack *firstAudioAssetTrack;
        for (AVAssetTrack *assetTrack in self.videoPlayer.player.currentItem.asset.tracks)
        {
            if ([assetTrack.mediaType isEqualToString:AVMediaTypeAudio])
            {
                firstAudioAssetTrack = assetTrack;
                break;
            }
        }
        if (firstAudioAssetTrack)
        {
            _audioTapProcessor = [[AddDelayAudioTapProcessor alloc] initWithAudioAssetTrack:firstAudioAssetTrack];
            
            NSAssert(_audioTapProcessor != nil, @"VideoPlayerViewController: error creating AudioTapProcessor");
        }
    }
    return _audioTapProcessor;
}



//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------


- (void) setFillMode:(NSString *)fillMode
{
    
    _fillMode = fillMode;
    [self.videoPlayer setVideoFillMode:fillMode];
}

//------------------------------------------------------------------------------

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    if (_delegate){
        [_delegate VideoPlayer:self.videoPlayer DurationAvailable:duration];
        
    }
    [self notifyObservers:VideoPlayerDurationNotification object:self userInfo:nil];
    
}

//------------------------------------------------------------------------------

- (void) setState:(VideoPlayerState)state
{
    _state = state;
    if (_delegate){
        [_delegate VideoPlayer:self.videoPlayer State:state];
        
    }
    [self notifyObservers:VideoPlayerDidChangePlayStateNotification object:self userInfo:nil];
}

//------------------------------------------------------------------------------



- (void) setVideoURL:(NSURL *) assetURL
{
    // make a deep copy of the URL
    _videoURL = [assetURL copy];
    
    if ([[_videoURL scheme]  isEqual: @"http"] || [[_videoURL scheme]  isEqual: @"https"])
    {
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           [self prepareToPlayHLSVideoStream:_videoURL withKeys:nil Error:nil];
                       });
        
    }else if ([_videoURL isFileURL]){
        
        NSDictionary *initOptionsSet = @{AVURLAssetPreferPreciseDurationAndTimingKey: @1};
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_videoURL options:initOptionsSet];
        
        NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, kDuration, nil];
        
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                
                                NSError *error;
                                BOOL success = [self prepareToPlayAsset:asset
                                                withKeys:requestedKeys
                                                   Error:&error];
                                if (!success) {
                                    NSLog(@"setVideoURL: %@", error);
                                }
                                
                            });
         }];
        
    }
}

//------------------------------------------------------------------------------

- (void) setAudioOffset:(NSTimeInterval)audioOffset
{
    
    _audioOffset = audioOffset;
    
}

//------------------------------------------------------------------------------

- (void) setVideoOffset:(NSTimeInterval)videoOffset
{
    
    
    _videoOffset = videoOffset;
    
    
    
}



//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void) stopAndRemoveFromParentView
{
    [self.videoPlayer.player pause];
    [self.videoPlayer.player cancelPendingPrerolls];
    
    // --- remove all observers ---
    // remove AVPlayer time observers
    [self.videoPlayer.player removeTimeObserver:self.playerObserver];
    
    for (AVPlayerControllerObserver *observer in timeObserversArray) {
        [self.videoPlayer.player removeTimeObserver:observer.observingObject];
    }
    
    // remove KVO observers
    [self.playerItem removeObserver:self forKeyPath:kStatusKey context:VideoPlayerStatusObservationContext];
    
    [self.playerItem removeObserver:self forKeyPath:kTracksKey context:VideoPlayerTracksObservationContext];
    
    [self.playerItem removeObserver:self forKeyPath:kLoadedTimeRangesKey context:VideoPlayerBufferingObservationContext];
    
    [self.videoPlayer.player removeObserver:self forKeyPath:kCurrentItemKey context:VideoPlayerCurrentItemObservationContext];
    
    // unsubscribe from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.videoPlayer removeFromSuperview];
    self.videoPlayer.player = nil;
    self.videoPlayer.parentView = nil;
    self.videoPlayer = nil;
    self.delegate = nil;
}

//------------------------------------------------------------------------------

- (void) pause
{
    [self.videoPlayer.player pause];
    self.state = VideoPlayerStatePaused;
    self.isPlaying = NO;
}

//------------------------------------------------------------------------------

- (void) play
{
    [self.videoPlayer.player play];
    self.state = VideoPlayerStatePlaying;
    self.isPlaying = YES;
}

//------------------------------------------------------------------------------

- (void) setRate: (float) rate
{
    [self.videoPlayer.player setRate:rate];
    
    self.state = VideoPlayerStatePlaying;
    self.isPlaying = YES;
}


//------------------------------------------------------------------------------

- (void) setRate: (float)rate time:(Float64)itemTime atHostTime:(Float64)hostClockTime
{
    self.state = VideoPlayerStateSeeking;
    self.isPlaying = YES;
    
    CMTime mediaObjectTime = CMTimeMake(itemTime/1000, 1000000);
    CMTime hostTime =  CMTimeMake(hostClockTime, 1000000000);
    
    [self.videoPlayer.player setRate:rate time:mediaObjectTime atHostTime:hostTime];
    
    self.state = VideoPlayerStatePlaying;
    
}

//------------------------------------------------------------------------------

- (void) seekToTime:(Float64) time
{
    self.state = VideoPlayerStateSeeking;
    self.isPlaying = YES;
    
    CMTime mediaObjectTime = CMTimeMakeWithSeconds(time, 1000000);
    [self.playerItem seekToTime:mediaObjectTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    self.state = VideoPlayerStatePlaying;
}

//------------------------------------------------------------------------------


- (BOOL) addPeriodicTime:(uint32_t) periodMs Observer: (id) observer
{
    
    NSUInteger index = [self getIndexofPlayerObserver:observer ];
    if (index != NSNotFound) [self removePeriodicTimeObserver:observer];
    
    
    AVPlayerControllerObserver *obj = [[AVPlayerControllerObserver alloc] init];
    
    obj.observingObject = observer;
    obj.periodMs = periodMs;
    
    [timeObserversArray addObject:observer];
    
    __weak VideoPlayerViewController *weakSelf = self;
    
    // if media playback is observable, register additional observers for its timeline progress
    if (_playerObserver)
    {
        CMTime interval = CMTimeMake(periodMs, 1000);
        obj.avPlayerTimeObserver = [self.videoPlayer.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue()usingBlock: ^(CMTime time) {
            [weakSelf sendVideoPlayerCurrentTimeNotification: nil];
        }];
    }

    
    return YES;
}

//------------------------------------------------------------------------------

- (void) removePeriodicTimeObserver:(id) observer
{
    NSUInteger index = [self getIndexofPlayerObserver:observer];
    
    if (index != NSNotFound)
    {
        AVPlayerControllerObserver *a = (AVPlayerControllerObserver*)[timeObserversArray objectAtIndex:index];
        
        [self.videoPlayer.player removeTimeObserver:a.avPlayerTimeObserver];
        [timeObserversArray removeObjectAtIndex:index];
    }

}

//------------------------------------------------------------------------------




//------------------------------------------------------------------------------
#pragma mark - Key value observation handler
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    
    if (context == VideoPlayerStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        if (status == AVPlayerStatusReadyToPlay) {
            
            
            if (_playerObserver == nil)
            {
                [self.videoPlayer.player prerollAtRate:1.0f completionHandler:^(BOOL finished) {
                }];
                
                // get duration of AVAsset
                CMTime duration = [[[[[self.playerItem tracks] objectAtIndex:0] assetTrack] asset] duration];
                
                //  ---- update duration property and notify observers ----
                _duration = CMTimeGetSeconds(duration);
                
                if (self.delegate)
                {
                     /* update delegate asynchronously with duration */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate VideoPlayer:self.videoPlayer DurationAvailable:_duration];
                    });
                }
                
                [self notifyObservers:VideoPlayerDurationNotification object:self userInfo:nil];
                
                 // update currentTime and register periodic time observers
                _currentTime = CMTimeGetSeconds(self.videoPlayer.player.currentItem.currentTime);
                
                __weak VideoPlayerViewController *weakSelf = self;
                
                // register a default time observer with block to call notify every 100ms
                CMTime interval = CMTimeMake(100, 1000);
                
                self.playerObserver = [self.videoPlayer.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue()usingBlock: ^(CMTime time) {
 
                    [weakSelf.delegate VideoPlayer:weakSelf.videoPlayer updatedPosition:CMTimeGetSeconds(weakSelf.videoPlayer.player.currentItem.currentTime)];
                    [weakSelf sendVideoPlayerCurrentTimeNotification: nil];
                    
                }];

                
                // register additional time observers
                for (AVPlayerControllerObserver *temp in timeObserversArray) {
                   
                    CMTime interval = CMTimeMake(temp.periodMs, 1000);
                    temp.avPlayerTimeObserver = [self.videoPlayer.player addPeriodicTimeObserverForInterval:interval
                                                                                                      queue:dispatch_get_main_queue()
                                                                                                  usingBlock: ^(CMTime time) {
                                                                                                      [weakSelf sendVideoPlayerCurrentTimeNotification: temp.observingObject];
                                                                                                  }];
                }
                
                
                // Add audio mix with audio tap processor to current player item.
                AVAudioMix *audioMix = self.audioTapProcessor.audioMix;
                if (audioMix)
                {
                    // Add audio mix with first audio track.
                    self.videoPlayer.player.currentItem.audioMix = audioMix;
                   }
                
                // Forward value to audio tap processor.
                self.audioTapProcessor.enableDelayFilter = true;
                self.audioTapProcessor.delayInMilliSecs = self.audioOffset;
                
                
                self.state = VideoPlayerStateReadyToPlay;
                
                
            }
        }
        
    } else if (context == VideoPlayerCurrentItemObservationContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem) {
            self.playerItem = newPlayerItem;
            [self.videoPlayer setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
    } else if (context == VideoPlayerTracksObservationContext)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate VideoPlayer:self.videoPlayer TrackInfoAvailable:self.playerItem.tracks];
        });
    }else if (context == VideoPlayerBufferingObservationContext)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate VideoPlayer:self.videoPlayer LoadedTimeRanges:self.playerItem.loadedTimeRanges];
        });
    }
    else{
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Private methods
//------------------------------------------------------------------------------

- (BOOL) prepareToPlayAsset:(AVURLAsset *)asset
                   withKeys:(NSArray *)requestedKeys
                      Error:(NSError**) error {
    
    // check if all keys available for asset
    for (NSString *thisKey in requestedKeys) {
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:error];
        if (keyStatus == AVKeyValueStatusFailed) {
            return NO;
        }
    }
    
    // check if asset can be played
    if (!asset.playable) {
        *error = [VideoPlayerError errorAVAssetNotPlayable:asset];
        return NO;
    }
    
    // if video player was playing an existing AVPlayerItem,
    // 1. remove subscription to the AVPlayerItem's key value observations
    // 2. remove subscription to AVPlayerItem notifications
    if (self.playerItem) {
        
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:[self.playerItem copy]];
    }
    
    // ---- create AVPlayerItem from asset and register for property value changes ----
    
    // create an AVPlayerItem with asset
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // register to AVPlayerItem for KVO status observations using status key
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerStatusObservationContext];
    
    // register to AVPlayerItem for KVO observations using tracks key
    [self.playerItem addObserver:self
                      forKeyPath:kTracksKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerTracksObservationContext];
    
    // register to AVPlayerItem for KVO observations using LoadedTimeRanges key
    [self.playerItem addObserver:self
                      forKeyPath:kLoadedTimeRangesKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerBufferingObservationContext];
    
    // subscribe to the AVPlayerItem's notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    // create/update videoPlayer with AVPlayerItem
    if (!self.videoPlayer.player) {
        [self.videoPlayer setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];

        [self.videoPlayer.player addObserver:self
                                  forKeyPath:kCurrentItemKey
                                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                     context:VideoPlayerCurrentItemObservationContext];
    }
    
    if (self.videoPlayer.player.currentItem != self.playerItem) {
        [self.videoPlayer.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    
    self.state = VideoPlayerStateInitalised;
    
    return YES;
}

//------------------------------------------------------------------------------

/** Prepare AV player to start playing HLS video stream */
- (BOOL) prepareToPlayHLSVideoStream:(NSURL *)url withKeys:(NSArray *)requestedKeys  Error:(NSError *__autoreleasing *)error
{
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    
    // register to AVPlayerItem for KVO status observations using status key
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerStatusObservationContext];
    
    // register to AVPlayerItem for KVO observations using tracks key
    [self.playerItem addObserver:self
                      forKeyPath:kTracksKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerTracksObservationContext];
    
    // register to AVPlayerItem for KVO observations using LoadedTimeRanges key
    [self.playerItem addObserver:self
                      forKeyPath:kLoadedTimeRangesKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerBufferingObservationContext];
    
    // subscribe to the AVPlayerItem's notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    if (!self.videoPlayer.player) {
        
        
        
        [self.videoPlayer setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        [self.videoPlayer.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:VideoPlayerCurrentItemObservationContext];
    }
    
    if (self.videoPlayer.player.currentItem != self.playerItem) {
        [self.videoPlayer.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    
     self.state = VideoPlayerStateInitalised;
    
    return YES;
}

//------------------------------------------------------------------------------

/** private method: send a media-playback timestamp to kAVPlayerCurrentTimeNotif observers*/
- (void)sendVideoPlayerCurrentTimeNotification: (id) observer
{
//    NSMutableDictionary *timestamp_dict = [NSMutableDictionary dictionary];
//    
//    [timestamp_dict setObject:[NSNumber numberWithDouble: self.currentTime] forKey:VideoPlayerCurrentTimeNotification];
//    
//    [self notifyObservers:VideoPlayerCurrentTimeNotification object:self userInfo:timestamp_dict];
}

//------------------------------------------------------------------------------

- (NSUInteger) getIndexofPlayerObserver:(id) observingObj
{
    AVPlayerControllerObserver *temp;
    AVPlayerControllerObserver *comparator;
    
    if ([observingObj isKindOfClass:[AVPlayerControllerObserver class]]){
        comparator = (AVPlayerControllerObserver*) observingObj;
        
        
        for (int i=0; i < [timeObserversArray count]; i++)
        {
            temp = (AVPlayerControllerObserver*) timeObserversArray[i];
            
            if ([temp.observingObject isEqual:comparator.observingObject])
                return i;
        }
    }
    
    return NSNotFound;
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
#pragma mark - Notification Handlers
//------------------------------------------------------------------------------

/**
 *  AVPlayerItemDidPlayToEndTimeNotification handler
 *
 *  @param notification a AVPlayerItemDidPlayToEndTimeNotification
 */
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    self.state = VideoPlayerStateEndOfVideo;
    
    NSLog(@"VideoPlayerViewController: reached end of video");
    
    if (self.shouldLoop){
        [self.videoPlayer.player seekToTime:kCMTimeZero];
        NSLog(@"VideoPlayerViewController: looping video playback");
        [self play];
    }
}













@end
