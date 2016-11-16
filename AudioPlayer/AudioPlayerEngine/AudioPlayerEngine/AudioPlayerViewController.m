//
//  SyncAudioPlayerView.m
//  Acolyte
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

#import "AudioPlayerViewController.h"





//------------------------------------------------------------------------------
#pragma mark - AudioPlayerViewController (Interface Extension)
//------------------------------------------------------------------------------
@interface AudioPlayerViewController()


@end



//------------------------------------------------------------------------------
#pragma mark - AudioPlayer (Implementation)
//------------------------------------------------------------------------------
@implementation AudioPlayerViewController
{
    
    NSNotificationCenter*   notificationCenter;

   
    
}


//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype) initWithAudioFilePath:(NSString *) audioFilePath
                            ParentView:(UIView*) parentView
{
    self = [super init];
    if(self){
        
        // --- create view ---
        
        self.parentView =parentView;
        CGRect frame = CGRectMake(parentView.bounds.origin.x, parentView.bounds.origin.y, parentView.bounds.size.width, parentView.bounds.size.height);
        
        self.audioPlot = [[EZAudioPlotGL alloc] initWithFrame:frame];
        
        // --- Customise the audio plot's look ---
        // Background color
        self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.10 green: 0.10 blue: 0.10 alpha: 1];
        // Waveform color
        self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        // Plot type
        self.audioPlot.plotType        = EZPlotTypeBuffer;
        // Fill
        self.audioPlot.shouldFill      = NO;
        // Mirror
        self.audioPlot.shouldMirror    = NO;
        [self.parentView addSubview:self.audioPlot];
        
        // --- open the audio file and start playing ---
        //NSString *filename = [audioFilePath stringByDeletingPathExtension];
        NSString *fileExt = [audioFilePath pathExtension];
       
        self.audioFileURL = audioFilePath;
        
        self.player = [AudioPlayer audioPlayerWithDelegate:self];
        self.player.shouldLoop = YES;
        
        
        [self _configureAudioPlayer];
        
        [self openFileWithFilePathURL:[NSURL fileURLWithPath:self.audioFileURL]];
        
     
        
        // ---- callibrate our audio player with offsets -----
        // these offsets were measured using the DVB CSS Callibration Toolkit
        // see https://github.com/bbc/dvbcss-synctiming
        
        if ([fileExt compare:@"aac" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            self.player.offset  = 0; //54.83ms  -54.83e-3
        else if ([fileExt compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            self.player.offset  = 0; // -27.06e-3
        
    }
    
    return self;
}

//------------------------------------------------------------------------------

- (instancetype) initWithAudioFilePath:(NSString *) audioFilePathURL
                            ParentView:(UIView*) parentView
                              Delegate:(id<AudioPlayerVCDelegate>) vcdelegate
{
    self.delegate = vcdelegate;
    
    return [self initWithAudioFilePath:audioFilePathURL ParentView:parentView];
}


//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Private Methods
//------------------------------------------------------------------------------

- (void) _configureAudioPlayer {

    // Configure the AVSession
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = NULL;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if( err ){
        NSLog(@"There was an error creating the audio session");
    }
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    if( err ){
        NSLog(@"There was an error sending the audio to the speakers");
    }

    
}

//------------------------------------------------------------------------------

-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
     {
         [weakSelf.audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
     }];
    
    //
    // Play the audio file
    //
    [self.player setAudioFile:self.audioFile];
    [self.player play];
    
}
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------


- (void) playAudioFile:(NSString*)filePathURL
{
    NSString *filename = [filePathURL stringByDeletingPathExtension];
    NSString *fileExt = [filePathURL pathExtension];
    NSString * mediaUrl =  [[NSBundle mainBundle] pathForResource:filename ofType:fileExt];
    self.audioFileURL = mediaUrl;
    
    [self _configureAudioPlayer];
    
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:self.audioFileURL]];
    
    
    // ---- callibrate our audio player with offsets -----
    // these offsets were measured using the DVB CSS Callibration Toolkit
    // see https://github.com/bbc/dvbcss-synctiming
    
    if ([fileExt compare:@"aac" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        self.player.offset  = -54.83e-3; //54.83ms
    else if ([fileExt compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        self.player.offset  = -27.06e-3; // 27.06ms
}

//------------------------------------------------------------------------------

- (void) play
{
    if ([self.player isPlaying])
    {
        [self.player pause];
    }
    else
    {
        if (self.audioPlot.shouldMirror && (self.audioPlot.plotType == EZPlotTypeBuffer))
        {
            self.audioPlot.shouldMirror = NO;
            self.audioPlot.shouldFill = NO;
        }
        [self.player play];
    }
}

//------------------------------------------------------------------------------

- (void) stopPlayerAndRemoveView
{
    
    
    if( _audioFile ){
        
        [self.player.output stopPlayback];
        [self.audioPlot pauseDrawing];
        [self.audioPlot clear];
        
        [self.audioPlot removeFromSuperview];
        
    }
    
  
    
}


//------------------------------------------------------------------------------


/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
 */
-(void)drawBufferPlot {
    // Change the plot type to the buffer plot
    self.audioPlot.plotType = EZPlotTypeBuffer;
    // Don't fill
    self.audioPlot.shouldFill = NO;
    // Don't mirror over the x-axis
    self.audioPlot.shouldMirror = NO;
}

//------------------------------------------------------------------------------

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
    // Change the plot type to the rolling plot
    self.audioPlot.plotType = EZPlotTypeRolling;
    // Fill the waveform
    self.audioPlot.shouldFill = YES;
    // Mirror over the x-axis
    self.audioPlot.shouldMirror = YES;
}

//------------------------------------------------------------------------------

- (void) changePlotType: (NSInteger) plotIndex
{
    switch(plotIndex)
    {
        case 0:
            [self drawBufferPlot];
            break;
        case 1:
            [self drawRollingPlot];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------

- (void)seekToTime:(UInt64)timeInMilliSecs
{
    [self.player seekToTime:(timeInMilliSecs *1.0)/1000];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - AudioPlayerDelegate
//------------------------------------------------------------------------------

- (void)  audioPlayer:(AudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(AudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (weakSelf.delegate)
        {
            
            if ([weakSelf.delegate respondsToSelector:@selector(DidUpdateCurrentMediaTime:)])
            {
                [weakSelf.delegate DidUpdateCurrentMediaTime:([self.player currentTime]*1000)];
            }
        }
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(AudioPlayer *)audioPlayer
reachedEndOfAudioFile:(EZAudioFile *)audioFile
{
    [audioPlayer seekToFrame:0];
    
}




//------------------------------------------------------------------------------
#pragma mark - cleanup
//------------------------------------------------------------------------------

- (void) dealloc{
    _audioFile = nil;
    self.audioPlot = nil;
    self.parentView = nil;
    self.player = nil;
    self.delegate = nil;
    
    NSLog(@"AudioPlayerViewController deallocated");
}








@end
