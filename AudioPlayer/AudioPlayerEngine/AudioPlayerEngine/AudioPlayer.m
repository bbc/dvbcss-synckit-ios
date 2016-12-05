//
//  AudioPlayer.m
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

#import "AudioPlayer.h"



//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

NSString * const AudioPlayerDidChangeAudioFileNotification = @"AudioPlayerDidChangeAudioFileNotification";
NSString * const AudioPlayerDidChangeOutputDeviceNotification = @"AudioPlayerDidChangeOutputDeviceNotification";
NSString * const AudioPlayerDidChangePanNotification = @"AudioPlayerDidChangePanNotification";
NSString * const AudioPlayerDidChangePlayStateNotification = @"AudioPlayerDidChangePlayStateNotification";
NSString * const AudioPlayerDidChangeVolumeNotification = @"AudioPlayerDidChangeVolumeNotification";
NSString * const AudioPlayerDidReachEndOfFileNotification = @"AudioPlayerDidReachEndOfFileNotification";
NSString * const AudioPlayerDidSeekNotification = @"AudioPlayerDidSeekNotification";


//------------------------------------------------------------------------------
#pragma mark - AudioPlayer (Interface Extension)
//------------------------------------------------------------------------------
@interface AudioPlayer()

#pragma mark properties

/**
 *  Audio player state value property
 */
@property (nonatomic, assign, readwrite) AudioPlayerState state;


@end


//------------------------------------------------------------------------------
#pragma mark - AudioPlayer (Implementation)
//------------------------------------------------------------------------------

@implementation AudioPlayer
{
    
    NSNotificationCenter*   notificationCenter;

    
}


//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)audioPlayer
{
    return [[self alloc] init];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithDelegate:(id<AudioPlayerDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile
{
    return [[self alloc] initWithAudioFile:audioFile];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile
                                delegate:(id<AudioPlayerDelegate>)delegate
{
    return [[self alloc] initWithAudioFile:audioFile
                                  delegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithURL:(NSURL *)url
                          delegate:(id<AudioPlayerDelegate>)delegate
{
    return [[self alloc] initWithURL:url delegate:delegate];
}


//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------


//- (id) initWithAudioAsset:(MediaItemModel*) mediaItem
//                    Material:(MaterialModel*) material
//                   WallClock: (ConfigurableClock*) wallclock
//{
//    self = [super init];
//    if(self){
////        startPTSNanos =  ((Float64)mediaItem.tvContentStartTimePTSTicks / 90000.0) * 1000000000;;
////        
////        self.wallClock = wallclock;
////        
////        self.audioAsset =  mediaItem;
////        
////        NSString *filename = [mediaItem.mediaURL stringByDeletingPathExtension];
////        NSString *ext = [mediaItem.mediaURL pathExtension];
////
////        if ([mediaItem.deliveryFormat compare:@"file" options: NSCaseInsensitiveSearch] == NSOrderedSame){
////            
////            NSString * mediaUrl =  [[NSBundle mainBundle] pathForResource:filename ofType:ext];
////            
////            self.audioFileURL = mediaUrl;
////            
////            // Defaults
////            self.output = [EZOutput sharedOutput];
////            [self _configureAudioPlayer];
////            
////            [self openFileWithFilePathURL:[NSURL fileURLWithPath:self.audioFileURL]];
////        }
////        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TimelineSyncNewControlTimeStampReceived:) name:kTimelineSyncNewControlTimeStamp object:nil];
//    }
//    return self;
//}

//------------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.offset = 0.0; // initialise audio offset
        self.output = [EZOutput sharedOutput];
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithDelegate:(id<AudioPlayerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.delegate = delegate;
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile
{
    return [self initWithAudioFile:audioFile delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile
                         delegate:(id<AudioPlayerDelegate>)delegate
{
    self = [self initWithDelegate:delegate];
    if (self)
    {
        self.audioFile = audioFile;
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
{
    return [self initWithURL:url delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<AudioPlayerDelegate>)delegate
{
    self = [self initWithDelegate:delegate];
    if (self)
    {
        self.audioFile = [EZAudioFile audioFileWithURL:url delegate:self];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

+ (instancetype)sharedAudioPlayer
{
    static AudioPlayer *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      player = [[self alloc] init];
                  });
    return player;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    self.output = [EZOutput output];
    self.state = AudioPlayerStateReadyToPlay;
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (NSTimeInterval)currentTime
{
    return ([self.audioFile currentTime]);
}

//------------------------------------------------------------------------------

- (EZAudioDevice *)device
{
    return [self.output device];
}

//------------------------------------------------------------------------------

- (NSTimeInterval)duration
{
    return [self.audioFile duration];
}

//------------------------------------------------------------------------------

- (NSString *)formattedCurrentTime
{
    return [self.audioFile formattedCurrentTime];
}

//------------------------------------------------------------------------------

- (NSString *)formattedDuration
{
    return [self.audioFile formattedDuration];
}

//------------------------------------------------------------------------------

- (SInt64)frameIndex
{
    return [self.audioFile frameIndex];
}

//------------------------------------------------------------------------------

- (BOOL)isPlaying
{
    return [self.output isPlaying];
}

//------------------------------------------------------------------------------

- (float)pan
{
    return [self.output pan];
}

//------------------------------------------------------------------------------

- (SInt64)totalFrames
{
    return [self.audioFile totalFrames];
}

//------------------------------------------------------------------------------

- (float)volume
{
    return [self.output volume];
}


//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setAudioFile:(EZAudioFile *)audioFile
{
    _audioFile = [audioFile copy];
    _audioFile.delegate = self;
    AudioStreamBasicDescription inputFormat = _audioFile.clientFormat;
    [self.output setInputFormat:inputFormat];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidChangeAudioFileNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    [self.audioFile setCurrentTime:currentTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidSeekNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)setDevice:(EZAudioDevice *)device
{
    [self.output setDevice:device];
}

//------------------------------------------------------------------------------

- (void)setOutput:(EZOutput *)output
{
    _output = output;
    _output.dataSource = self;
    _output.delegate = self;
}

//------------------------------------------------------------------------------

- (void)setPan:(float)pan
{
    [self.output setPan:pan];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidChangePanNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)setVolume:(float)volume
{
    [self.output setVolume:volume];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidChangeVolumeNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void) setOffset:(NSTimeInterval)offset
{
    NSTimeInterval currentTimeWithOffset = [self.audioFile currentTime] + offset;
    
    [self.audioFile setCurrentTime:currentTimeWithOffset];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)play
{
    [self.output startPlayback];
    self.state = AudioPlayerStatePlaying;
}

//------------------------------------------------------------------------------

- (void)playAudioFile:(EZAudioFile *)audioFile
{
    //
    // stop playing anything that might currently be playing
    //
    [self pause];
    
    //
    // set new stream
    //
    self.audioFile = audioFile;
    
    //
    // begin playback
    //
    [self play];
}

//------------------------------------------------------------------------------

- (void)pause
{
    [self.output stopPlayback];
    self.state = AudioPlayerStatePaused;
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(SInt64)frame
{
    self.state = AudioPlayerStateSeeking;
    [self.audioFile seekToFrame:frame];
    self.state = self.isPlaying ? AudioPlayerStatePlaying : AudioPlayerStatePaused;
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidSeekNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void) seekToTime:(Float64) timeInMS
{
    NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
    
    self.state = AudioPlayerStateSeeking;
    if( _audioFile ){
        [_audioFile seekToTime:timeInMS];
    }
    if( self.frameIndex != self.totalFrames ){
        
        self.state = self.isPlaying ? AudioPlayerStatePlaying : AudioPlayerStatePaused;
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidSeekNotification
                                                            object:self];
    
    }
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    if (self.audioFile)
    {
        UInt32 bufferSize;
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&eof];
        if (eof && [self.delegate respondsToSelector:@selector(audioPlayer:reachedEndOfAudioFile:)])
        {
            [self.delegate audioPlayer:self reachedEndOfAudioFile:self.audioFile];
        }
        if (eof && self.shouldLoop)
        {
            [self seekToFrame:0];
        }
        else if (eof)
        {
            [self pause];
            [self seekToFrame:0];
            self.state = AudioPlayerStateEndOfFile;
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidReachEndOfFileNotification
                                                                object:self];
        }
    }
    return noErr;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFileDelegate
//------------------------------------------------------------------------------

- (void)audioFileUpdatedPosition:(EZAudioFile *)audioFile
{
    if ([self.delegate respondsToSelector:@selector(audioPlayer:updatedPosition:inAudioFile:)])
    {
        [self.delegate audioPlayer:self
                   updatedPosition:[audioFile frameIndex]
                       inAudioFile:audioFile];
    }
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDelegate
//------------------------------------------------------------------------------

- (void)output:(EZOutput *)output changedDevice:(EZAudioDevice *)device
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidChangeOutputDeviceNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)output:(EZOutput *)output changedPlayingState:(BOOL)isPlaying
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerDidChangePlayStateNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)       output:(EZOutput *)output
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    if (_delegate){
    
    if ([self.delegate respondsToSelector:@selector(audioPlayer:playedAudio:withBufferSize:withNumberOfChannels:inAudioFile:)])
    {
        [self.delegate audioPlayer:self
                       playedAudio:buffer
                    withBufferSize:bufferSize
              withNumberOfChannels:numberOfChannels
                       inAudioFile:self.audioFile];
    }
    }
}

//------------------------------------------------------------------------------



@end
