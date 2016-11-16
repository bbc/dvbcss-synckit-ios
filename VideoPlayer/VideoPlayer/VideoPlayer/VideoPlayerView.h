//
//  VideoPlayerView.h
//  HLSVideoPlayer
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

@class AVPlayer;




//------------------------------------------------------------------------------
#pragma mark - VideoPlayerView
//------------------------------------------------------------------------------


/**
 *  A UIView sub-class encapsulating a native video player instance (AVPlayer)
 */
@interface VideoPlayerView : UIView

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  this UIView's AVPlayer video player instance
 */
@property (nonatomic, readwrite) AVPlayer *player;

//------------------------------------------------------------------------------


/**
 *  this player's parent view
 */
@property (nonatomic, readwrite) UIView *parentView;


//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

/**
 *  initialise this video player view with a frame.
 *
 *  @param frame A particular frame where view will be displayed.
 *
 *  @return VideoPlayerView instance.
 */
- (id) initWithFrame:(CGRect)frame;

/**
 *  initialise and add this video player as a subview to a parent UIView instance.
 *
 *  @param parentUIView a UIView within which to show video player.
 *
 *  @return VideoPlayerView instance.
 */
- (id) initWithParentView:(UIView*) parentUIView;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Set AVPlayer instance
 *
 *  @param player an AVPlayer object
 */
- (void) setPlayer:(AVPlayer *)player;

//------------------------------------------------------------------------------

/**
 *  Specifies how the video is displayed within the view-frame bounds.
 *
 *  @param fillMode constants such as AVLayerVideoGravityResizeAspect, AVLayerVideoGravityResizeAspectFill, and AVLayerVideoGravityResize. The default value is AVLayerVideoGravityResizeAspect.
 */
- (void) setVideoFillMode:(NSString*) fillMode;
//------------------------------------------------------------------------------


@end
