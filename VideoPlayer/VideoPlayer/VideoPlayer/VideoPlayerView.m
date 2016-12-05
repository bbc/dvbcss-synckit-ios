//
//  VideoPlayerView.m
//  HLSVideoPlayer
//
//  Created by Rajiv Ramdhany on 10/06/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

//  Copyright 2016 British Broadcasting Corporation
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

#import "VideoPlayerView.h"


//------------------------------------------------------------------------------
#pragma mark - AudioPlayer (Implementation)
//------------------------------------------------------------------------------

@implementation VideoPlayerView
{
    
}


//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


- (id) initWithParentView:(UIView*) parentUIView
{
    // create a frame for video player
    CGRect frame = CGRectMake(parentUIView.bounds.origin.x, parentUIView.bounds.origin.y, parentUIView.bounds.size.width, parentUIView.bounds.size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.parentView = parentUIView;
        [self.parentView addSubview:self];
        
    }
    return self;
    
}



//------------------------------------------------------------------------------

- (void) dealloc
{
    self.player = nil;
}


//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

+ (Class) layerClass {
	return [AVPlayerLayer class];
}

//------------------------------------------------------------------------------

- (AVPlayer*) player {
	return [(AVPlayerLayer*)[self layer] player];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setPlayer:(AVPlayer*)player {
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

//------------------------------------------------------------------------------

- (void)setVideoFillMode:(NSString *)fillMode {
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}


@end
