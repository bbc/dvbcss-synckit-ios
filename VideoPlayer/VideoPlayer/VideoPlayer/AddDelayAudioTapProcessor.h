//
//  AddDelayAudioTapProcessor.h
//  Acolyte
//
//  Created by Rajiv Ramdhany on 27/07/2015.

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

@class AVAudioMix;
@class AVAssetTrack;


//------------------------------------------------------------------------------
#pragma mark - AddDelayAudioTapProcessor
//------------------------------------------------------------------------------

/**
 An audio tap processor class which adds an offset to a video's audio track
 by adding silence for a number of samples at the begining of the buffer
 where audio samples are copied for the audio tap processor. 
 This class uses a circular buffer (https://github.com/michaeltyson/TPCircularBuffer) for writing the audio samples in and reading them out.
 Use initWithAudioAssetTrack designated initialiser.
  */
@interface AddDelayAudioTapProcessor : NSObject


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  Audio track of AV asset
 */
@property (readonly, nonatomic) AVAssetTrack *audioAssetTrack;

//------------------------------------------------------------------------------

/**
 *  Input parameters for mixing audio e.g. an audio tap processor object
 */
@property (readonly, nonatomic) AVAudioMix *audioMix;

//------------------------------------------------------------------------------

/**
 *  Is delay filter enabled
 */
@property (nonatomic, getter = isDelayFilterEnabled) BOOL enableDelayFilter;

//------------------------------------------------------------------------------

/**
 *  delay in milliseconds
 */
@property (nonatomic) UInt32 delayInMilliSecs;


//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

/**
 *  Designated initializer.
 *
 *  @param audioAssetTrack audio track of video asset
 *  @param delayInMs       delay for audio in milliseconds
 *
 *  @return instance of AddDelayAudioTapProcessor
 */
- (id) initWithAudioAssetTrack:(AVAssetTrack *)audioAssetTrack;

//------------------------------------------------------------------------------

@end
