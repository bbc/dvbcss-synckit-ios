//
//  AudioPlayer.h
//  Acolyte
//
//  Created by Rajiv Ramdhany on 06/03/2015.
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
#import <UIKit/UIKit.h>
#import "TargetConditionals.h"
#import "EZAudioFile.h"
#import "EZOutput.h"
#import "AudioStreamPlayer.h"




@class AudioPlayer;


//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, AudioPlayerState)
{
    AudioPlayerStateInitialised=0,
    AudioPlayerStateStartingFileThread,
    AudioPlayerStateWaitingForData,
    AudioPlayerStateFlushingEoF,
    AudioPlayerStateWaitingForQueueStart,
    AudioPlayerStateEndOfFile,
    AudioPlayerStatePaused,
    AudioPlayerStateBuffering,
    AudioPlayerStatePlaying,
    AudioPlayerStateStopping,
    AudioPlayerStateStopped,
    AudioPlayerStateReadyToPlay,
    AudioPlayerStateSeeking,
    AudioPlayerStateUnknown,
};



//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 Notification that occurs whenever the AudioPlayer changes its `audioFile` property. Check the new value using the AudioPlayer's `audioFile` property.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidChangeAudioFileNotification;

/**
 Notification that occurs whenever the AudioPlayer changes its `device` property. Check the new value using the AudioPlayer's `device` property.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidChangeOutputDeviceNotification;

/**
 Notification that occurs whenever the AudioPlayer changes its `output` component's `pan` property. Check the new value using the AudioPlayer's `pan` property.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidChangePanNotification;

/**
 Notification that occurs whenever the AudioPlayer changes its `output` component's play state. Check the new value using the AudioPlayer's `isPlaying` property.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidChangePlayStateNotification;

/**
 Notification that occurs whenever the AudioPlayer changes its `output` component's `volume` property. Check the new value using the AudioPlayer's `volume` property.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidChangeVolumeNotification;

/**
 Notification that occurs whenever the AudioPlayer has reached the end of a file and its `shouldLoop` property has been set to NO.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidReachEndOfFileNotification;

/**
 Notification that occurs whenever the AudioPlayer performs a seek via the `seekToFrame` method or `setCurrentTime:` property setter. Check the new `currentTime` or `frameIndex` value using the AudioPlayer's `currentTime` or `frameIndex` property, respectively.
 */
FOUNDATION_EXPORT NSString * const AudioPlayerDidSeekNotification;

//------------------------------------------------------------------------------
#pragma mark - AudioPlayerDelegate
//------------------------------------------------------------------------------

/**
 The AudioPlayerDelegate provides event callbacks for the AudioPlayer. AudioPlayerDelegate provides a small set of delegate methods in favor of notifications to allow multiple receivers of the AudioPlayer event callbacks since only one player is typically used in an application. Specifically, these methods are provided for high frequency callbacks that wrap the AudioPlayer's internal EZAudioFile and EZOutput instances.
 @warning These callbacks don't necessarily occur on the main thread so make sure you wrap any UI code in a GCD block like: dispatch_async(dispatch_get_main_queue(), ^{ // Update UI });
 */
@protocol AudioPlayerDelegate <NSObject>

@optional

//------------------------------------------------------------------------------

/**
 Triggered by the AudioPlayer's internal EZAudioFile's EZAudioFileDelegate callback and notifies the delegate of the read audio data as a float array instead of a buffer list. Common use case of this would be to visualize the float data using an audio plot or audio data dependent OpenGL sketch.
 @param audioPlayer The instance of the AudioPlayer that triggered the event
 @param buffer           A float array of float arrays holding the audio data. buffer[0] would be the left channel's float array while buffer[1] would be the right channel's float array in a stereo file.
 @param bufferSize       The length of the buffers float arrays
 @param numberOfChannels The number of channels. 2 for stereo, 1 for mono.
 @param audioFile   The instance of the EZAudioFile that the event was triggered from
 */
- (void)  audioPlayer:(AudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile;;

//------------------------------------------------------------------------------

/**
 Triggered by AudioPlayer's internal EZAudioFile's EZAudioFileDelegate callback and notifies the delegate of the current playback position. The framePosition provides the current frame position and can be calculated against the AudioPlayer's total frames using the `totalFrames` function from the AudioPlayer.
 @param audioPlayer The instance of the AudioPlayer that triggered the event
 @param framePosition The new frame index as a 64-bit signed integer
 @param audioFile   The instance of the EZAudioFile that the event was triggered from
 */
- (void)audioPlayer:(AudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Triggered by AudioPlayer's internal EZAudioFile's EZAudioFileDelegate callback and notifies the delegate that the end of the file has been reached.
 @param audioPlayer The instance of the AudioPlayer that triggered the event
 @param audioFile   The instance of the EZAudioFile that the event was triggered from
 */
- (void)audioPlayer:(AudioPlayer *)audioPlayer
reachedEndOfAudioFile:(EZAudioFile *)audioFile;
//------------------------------------------------------------------------------

@end


//------------------------------------------------------------------------------
#pragma mark - AudioPlayer
//------------------------------------------------------------------------------



/**
 *  @brief The AudioPlayer plays audio files using Core Audio services.
 
   @discussion To play audio files, the AudioPlayer uses the EZAudioFile and EZOutput objects. To play a file, the AudioPlayer creates an EZAudioFile instance to read audio data from the file. For playback of the audio data, it uses an EZOutput instance - this object makes use of AudioUnit to convert the audio data coming into a playback graph of audio processing units.
 
 
 This class acts as the master delegate (the EZAudioFileDelegate) over whatever EZAudioFile instance, the `audioFile` property, it is using for playback as well as the EZOutputDelegate and EZOutputDataSource over whatever EZOutput instance is set as the `output`. Classes that want to get the EZAudioFileDelegate callbacks should implement the AudioPlayer's AudioPlayerDelegate on the AudioPlayer instance.
 
 
 */
@interface AudioPlayer : NSObject <EZAudioFileDelegate,EZOutputDataSource, EZOutputDelegate>


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  An offset by which the audio playback can be moved forward or back. This is used typically to callibrate the playback so that currentTime reports the time when the sound actually reaches the speakers. There is no need take into account for the time it takes for the sound to travel to the listener's ears.
 */
@property (nonatomic, assign) NSTimeInterval offset;


//------------------------------------------------------------------------------

/**
 A BOOL indicating whether the player should loop the file
 */
@property (nonatomic, assign) BOOL shouldLoop;

//------------------------------------------------------------------------------

/**
 An AudioPlayerState value representing the current internal playback and file state of the AudioPlayer instance.
 */
@property (nonatomic, assign, readonly) AudioPlayerState state;

//------------------------------------------------------------------------------

/**
 Audio file URL. A file in the app's file system 
 */
@property (nonatomic,strong) NSString *audioFileURL;


//------------------------------------------------------------------------------


/**
 *  The EZAudioFile representing the currently selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;

//------------------------------------------------------------------------------

/**
 *  The AudioPlayerDelegate that will handle the audio player callbacks
 */
@property (nonatomic, strong) id<AudioPlayerDelegate> delegate;

//------------------------------------------------------------------------------

/**
 Provides the current offset in the audio file as an NSTimeInterval (i.e. in seconds).  When setting this it will determine the correct frame offset and perform a `seekToFrame` to the new time offset.
 @warning Make sure the new current time offset is less than the `duration` or you will receive an invalid seek assertion.
 */
@property (nonatomic, readwrite) NSTimeInterval currentTime;

//------------------------------------------------------------------------------

/**
 The EZAudioDevice instance that is being used by the `output`. Similarly, setting this just sets the `device` property of the `output`.
 */
@property (nonatomic, readwrite) EZAudioDevice *device;

//------------------------------------------------------------------------------

/**
 Provides the duration of the audio file in seconds.
 */
@property (readonly) NSTimeInterval duration;

//------------------------------------------------------------------------------

/**
 Provides the current time as an NSString with the time format MM:SS.
 */
@property (readonly) NSString *formattedCurrentTime;

//------------------------------------------------------------------------------

/**
 Provides the duration as an NSString with the time format MM:SS.
 */
@property (readonly) NSString *formattedDuration;

//------------------------------------------------------------------------------

/**
 Provides the EZOutput that is being used to handle the actual playback of the audio data. This property is also settable, but note that the AudioPlayer will become the output's EZOutputDataSource and EZOutputDelegate. To listen for the EZOutput's delegate methods your view should implement the AudioPlayerDelegate and set itself as the AudioPlayer's `delegate`.
 */
@property (nonatomic, strong, readwrite) EZOutput *output;

//------------------------------------------------------------------------------

/**
 Provides the frame index (a.k.a the seek positon) within the audio file being used for playback. This can be helpful when seeking through the audio file.
 @return An SInt64 representing the current frame index within the audio file used for playback.
 */
@property (readonly) SInt64 frameIndex;

//------------------------------------------------------------------------------

/**
 Provides a flag indicating whether the AudioPlayer is currently playing back any audio.
 @return A BOOL indicating whether or not the AudioPlayer is performing playback,
 */
@property (readonly) BOOL isPlaying;

//------------------------------------------------------------------------------

/**
 Provides the current pan from the audio player's internal `output` component. Setting the pan adjusts the direction of the audio signal from left (0) to right (1). Default is 0.5 (middle).
 */
@property (nonatomic, assign) float pan;

//------------------------------------------------------------------------------

/**
 Provides the total amount of frames in the current audio file being used for playback.
 @return A SInt64 representing the total amount of frames in the current audio file being used for playback.
 */
@property (readonly) SInt64 totalFrames;

//------------------------------------------------------------------------------

/**
 Provides the file path that's currently being used by the player for playback.
 @return  The NSURL representing the file path of the audio file being used for playback.
 */
@property (nonatomic, copy, readonly) NSURL *url;

//------------------------------------------------------------------------------

/**
 Provides the current volume from the audio player's internal `output` component. Setting the volume adjusts the gain of the output between 0 and 1. Default is 1.
 */
@property (nonatomic, assign) float volume;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

/**
 Initializes the AudioPlayer with an EZAudioFile instance. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the AudioPlayer
 @return The newly created instance of the AudioPlayer
 */
- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Initializes the AudioPlayer with an EZAudioFile instance and provides a way to assign the AudioPlayerDelegate on instantiation. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the AudioPlayer
 @param delegate The receiver that will act as the AudioPlayerDelegate. Set to nil if it should have no delegate or use the initWithAudioFile: function instead.
 @return The newly created instance of the AudioPlayer
 */
- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile
                         delegate:(id<AudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Initializes the AudioPlayer with an AudioPlayerDelegate.
 @param delegate The receiver that will act as the AudioPlayerDelegate. Set to nil if it should have no delegate or use the initWithAudioFile: function instead.
 @return The newly created instance of the AudioPlayer
 */
- (instancetype)initWithDelegate:(id<AudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Initializes the AudioPlayer with an NSURL instance representing the file path of the audio file.
 @param url The NSURL instance representing the file path of the audio file.
 @return The newly created instance of the AudioPlayer
 */
- (instancetype)initWithURL:(NSURL*)url;

//------------------------------------------------------------------------------

/**
 Initializes the AudioPlayer with an NSURL instance representing the file path of the audio file and a caller to assign as the AudioPlayerDelegate on instantiation.
 @param url The NSURL instance representing the file path of the audio file.
 @param delegate The receiver that will act as the AudioPlayerDelegate. Set to nil if it should have no delegate or use the initWithAudioFile: function instead.
 @return The newly created instance of the AudioPlayer
 */
- (instancetype)initWithURL:(NSURL*)url
                   delegate:(id<AudioPlayerDelegate>)delegate;



//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class initializer that creates a default EZAudioPlayer.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayer;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an EZAudioFile instance. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the EZAudioPlayer
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an EZAudioFile instance and provides a way to assign the EZAudioPlayerDelegate on instantiation. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the EZAudioPlayer
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the audioPlayerWithAudioFile: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile
                                delegate:(id<AudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Class initializer that creates a default EZAudioPlayer with an EZAudioPlayerDelegate..
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithDelegate:(id<AudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an NSURL instance representing the file path of the audio file.
 @param url The NSURL instance representing the file path of the audio file.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithURL:(NSURL*)url;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an NSURL instance representing the file path of the audio file and a caller to assign as the EZAudioPlayerDelegate on instantiation.
 @param url The NSURL instance representing the file path of the audio file.
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the audioPlayerWithURL: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithURL:(NSURL*)url
                          delegate:(id<AudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------

/**
 The shared instance (singleton) of the audio player. Most applications will only have one instance of the EZAudioPlayer that can be reused with multiple different audio files.
 *  @return The shared instance of the EZAudioPlayer.
 */
+ (instancetype)sharedAudioPlayer;



//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Controlling Playback
///-----------------------------------------------------------

/**
 Starts playback.
 */
- (void)play;

//------------------------------------------------------------------------------

/**
 Loads an EZAudioFile and immediately starts playing it.
 @param audioFile An EZAudioFile to use for immediate playback.
 */
- (void)playAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Pauses playback.
 */
- (void)pause;

//------------------------------------------------------------------------------

/**
 Seeks playback to a specified frame within the internal EZAudioFile. This will notify the EZAudioFileDelegate (if specified) with the audioPlayer:updatedPosition:inAudioFile: function.
 @param frame The new frame position to seek to as a SInt64.
 */
- (void)seekToFrame:(SInt64)frame;
//------------------------------------------------------------------------------

/**
 *  Seek to time position in milliseconds
 *  @param timeInMS time in milliseconds
 */
- (void) seekToTime:(Float64) timeInMS;

//------------------------------------------------------------------------------



@end
