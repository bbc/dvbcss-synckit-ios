//
//  ViewController.h
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

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIView *audioPlot;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *rollingHistorySlider;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider;
@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;

@property (weak, nonatomic) IBOutlet UIView *controlsView;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

//
// Switches the plot drawing type between a buffer plot (visualizes the current
// stream of audio data from the update function) or a rolling plot (visualizes
// the audio data over time, this is the classic waveform look)
//
- (IBAction)changePlotType:(id)sender;

//------------------------------------------------------------------------------

//
// Changes the length of the rolling history of the audio plot.
//
- (IBAction)changeRollingHistoryLength:(id)sender;

//------------------------------------------------------------------------------

//
// Changes the volume of the audio player.
//
- (IBAction)changeVolume:(id)sender;

//------------------------------------------------------------------------------

//
// Begins playback if a file is loaded. Pauses if the file is already playing.
//
- (IBAction)play:(id)sender;

//------------------------------------------------------------------------------

//
// Seeks to a specific frame in the audio file.
//
- (IBAction)seekToFrame:(id)sender;


@end

