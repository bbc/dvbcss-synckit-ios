//
//  SyncAudioPlayerView.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EZAudioFile.h"
#import "AudioPlayer.h"
#import "EZAudioPlotGL.h"




/**
 *  Callback methods for reporting playback progress information.
 */
@protocol AudioPlayerVCDelegate <NSObject>

@optional
/**
 *  Callback with updated current media time
 *
 *  @param timeInMs current media time
 */
- (void) DidUpdateCurrentMediaTime:(float) timeInMs;

//------------------------------------------------------------------------------



@end


/**
 *  This class represents a UIView controller for a view showing a vlsualisation for an encapsulated
 *  AudioPlayer (an audio player object). 
 */
@interface AudioPlayerViewController:UIViewController <AudioPlayerDelegate>


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  An EZAudioFile that will be used to load the audio file at the file path specified
 */
@property (nonatomic, strong) EZAudioFile *audioFile;

//------------------------------------------------------------------------------

/**
 *  An EZAudioPlayer that will be used for playback
 */
@property (nonatomic, strong) AudioPlayer *player;

//------------------------------------------------------------------------------
/**
 *  Parent UIView to which this controller's view is attached.
 */
@property (nonatomic, weak) UIView *parentView;

//------------------------------------------------------------------------------
/**
 *  A CoreGraphics-based audio plotting UIView
 */
@property (nonatomic, strong)EZAudioPlotGL *audioPlot;

//------------------------------------------------------------------------------
/**
 Audio file URL. A file in the app's file system 
 */
@property (nonatomic,strong) NSString *audioFileURL;

//------------------------------------------------------------------------------

/**
 *  This view controller's delegate (to provide asset playback information callbacks)
 */
@property (nonatomic, weak) id<AudioPlayerVCDelegate> delegate;


//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------


/**
 *  Initialise SyncAudioPlayerViewController instance with an audio asset and a parent view
 *
 *  @param audioFilePath file path for audio asset
 *  @param parentView    parent UIView object to attach the view that this UIViewController object controls
 *
 *  @return instance
 */
- (instancetype) initWithAudioFilePath:(NSString *) audioFilePathURL
               ParentView:(UIView*) parentView;

//------------------------------------------------------------------------------


/**
 *  Initialise SyncAudioPlayerViewController instance with an audio asset, a parent view and 
 *  a delegate object for receiving callbacks (for playback progress information).
 *
 *  @param audioFilePath file path for audio asset
 *  @param parentView    parent UIView object to attach the view that this UIViewController object
 *  @param vcdelegate    an object that conforms to AudioPlayerVCDelegate protocol
 *
 *  @return instance of AudioPlayerViewController
 */
- (instancetype) initWithAudioFilePath:(NSString *) audioFilePathURL
                            ParentView:(UIView*) parentView
                              Delegate:(id<AudioPlayerVCDelegate>) vcdelegate;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------


/**
 *  toggle play and pause modes for player.
 */
- (void) play;

//------------------------------------------------------------------------------


/**
 *  Stop the encapsulated audio player and remove the UIView from its superview.
 */
- (void) stopPlayerAndRemoveView;

//------------------------------------------------------------------------------

/**
 *  Plan an audio file and show visualisation
 *
 *  @param filePathURL an NSURL object representing a file path URL
 */
- (void) playAudioFile:(NSString*)filePathURL;

//------------------------------------------------------------------------------

/**
 *  Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
 */
- (void) drawBufferPlot;

//------------------------------------------------------------------------------

/**
 *  Give the classic mirrored, rolling waveform look
 */
- (void) drawRollingPlot;


//------------------------------------------------------------------------------

/**
 *  Change visualization: 0 for buffer waveform and 1 for rolling waveform
 *
 *  @param plotIndex plot style, 0 or 1
 */
- (void) changePlotType: (NSInteger) plotIndex;

//------------------------------------------------------------------------------

/**
 *  Cause the internal audio player to seek to new position
 *
 *  @param timeInMilliSecs new playhead position
 */
- (void) seekToTime:(UInt64) timeInMilliSecs;

//------------------------------------------------------------------------------

@end
