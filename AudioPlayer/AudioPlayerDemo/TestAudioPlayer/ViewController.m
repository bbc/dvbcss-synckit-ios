//
//  ViewController.m
//  TestAudioPlayer
//
//  Created by Rajiv Ramdhany on 16/02/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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

#import "ViewController.h"
#import <AudioPlayerEngine/EZAudio.h>



#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

@interface ViewController () <AudioPlayerVCDelegate>

@end

@implementation ViewController
{
    
    AudioPlayerViewController* audioPlayerVC;
    
    
}



//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.audioPlot bringSubviewToFront:self.controlsView];
    
    //
    // Customize UI components
    //
    self.rollingHistorySlider.value = (float)[audioPlayerVC.audioPlot rollingHistoryLength];
    
    //
    // Listen for EZAudioPlayer notifications
    //
    [self setupNotifications];
    
    audioPlayerVC = [[AudioPlayerViewController alloc] initWithAudioFilePath:kAudioFileDefault ParentView:self.audioPlot Delegate:self];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:AudioPlayerDidChangeAudioFileNotification
                                               object:audioPlayerVC.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:AudioPlayerDidChangeOutputDeviceNotification
                                               object:audioPlayerVC.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:AudioPlayerDidChangePlayStateNotification
                                               object:audioPlayerVC.player];
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
#pragma mark - Actions
//------------------------------------------------------------------------------
- (IBAction)changePlotType:(id)sender{
    
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    switch(selectedSegment)
    {
        case 0:
            [audioPlayerVC drawBufferPlot];
            break;
        case 1:
            [audioPlayerVC drawRollingPlot];
            break;
        default:
            break;
    }
    
}

//------------------------------------------------------------------------------

//
// Changes the length of the rolling history of the audio plot.
//
- (IBAction)changeRollingHistoryLength:(id)sender{
    float value = [(UISlider *)sender value];
    [audioPlayerVC.audioPlot setRollingHistoryLength:(int)value];
    
}

//------------------------------------------------------------------------------

//
// Changes the volume of the audio player.
//
- (IBAction)changeVolume:(id)sender{
    
    float value = [(UISlider *)sender value];
    [audioPlayerVC.player setVolume:value];
    
}

//------------------------------------------------------------------------------

//
// Begins playback if a file is loaded. Pauses if the file is already playing.
//
- (IBAction)play:(id)sender{
    if ([audioPlayerVC.player isPlaying])
    {
        [audioPlayerVC.player pause];
    }
    else
    {
        if (audioPlayerVC.audioPlot.shouldMirror && (audioPlayerVC.audioPlot.plotType == EZPlotTypeBuffer))
        {
            audioPlayerVC.audioPlot.shouldMirror = NO;
            audioPlayerVC.audioPlot.shouldFill = NO;
        }
        [audioPlayerVC.player play];
    }

}

//------------------------------------------------------------------------------

//
// Seeks to a specific frame in the audio file.
//
- (IBAction)seekToFrame:(id)sender{
    
    [audioPlayerVC.player seekToTime:([(UISlider *)sender value]*1000)];
}




//------------------------------------------------------------------------------
#pragma mark - AudioPlayerVCDelegate methods
//------------------------------------------------------------------------------

- (void) DidUpdateCurrentMediaTime:(float) timeInMs{
    
    
    float progr=0;
   // NSString* str = [NSString stringWithFormat:@"%.2f s", timeInMs];
   
    if (audioPlayerVC.player.duration > 0)
    {
        progr= timeInMs/ (audioPlayerVC.player.duration*1000);
//        NSLog(@"duration =%f, currentTime=%f progress = %f", audioPlayerVC.player.duration, timeInMs,progr);
        self.positionSlider.value = progr;
        
    }

}

@end
