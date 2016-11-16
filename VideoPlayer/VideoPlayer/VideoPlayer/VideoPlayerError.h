//
//  VideoPlayerError.h
//  Complis
//
//  Created by Rajiv Ramdhany on 23/03/2016.
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

/**
 *  Video Player error types
 */
typedef NS_ENUM(int, kVideoPlayerErrorTypes) {
    /**
     *  invalid URL
     */
    kVideoPlayerErrorInvalidVideoURL = 1,
    /**
     *  Bad response
     */
    kVideoPlayerErrorBadResponse = 2,
    /**
     *  Unsupported media format
     */
    kVideoPlayerErrorUnsupportedFormat = 3,
    /**
     *  Video format does not support seeking
     */
    kVideoPlayerErrorSeekingNotPossible = 4,
    /**
     *  Requested keys not available
     */
    kVideoPlayerErrorKeysUnavailable= 5,
    /**
     *  Video asset cannot be played
     */
    kVideoPlayerAVAssetNotPlayable = 6
};


//------------------------------------------------------------------------------

/** The domain name used for the VideoPlayerError instances */
extern NSString* const VideoPlayerErrorDomain;

extern NSString* const kVideoPlayerInvalidAsset;
extern NSString* const kVideoPlayerBadServerResponse;
extern NSString* const kVideoPlayerBadFormat;
extern NSString* const kVideoPlayerMediaKeysNotLoaded;
//------------------------------------------------------------------------------
#pragma mark - VideoPlayerError
//------------------------------------------------------------------------------

/**
 *  Custom NSError subclass with shortcut methods for creating
 * the common VideoPlayer errors
 */
@interface VideoPlayerError : NSError

//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------

/**
 * Creates a VideoPlayerError instance with code kVideoPlayerErrorInvalidVideoURL = 1
 */
+(id)errorInvalidVideoURL:(NSString*) url;

//------------------------------------------------------------------------------

/**
 * Creates a VideoPlayerError instance with code kVideoPlayerErrorBadResponse = 2
 */
+(id)errorBadResponse: (NSString*) response;

//------------------------------------------------------------------------------

/**
 * Creates a VideoPlayerError instance with code kVideoPlayerErrorUnsupportedFormat = 3
 */
+(id)errorUnsupportedFormat:(NSString*) format;

//------------------------------------------------------------------------------


/**
 * Creates a VideoPlayerError instance with code kVideoPlayerErrorSeekingNotPossible = 4
 */
+(id)errorSeekingNotPossible;

//------------------------------------------------------------------------------

/**
 * Creates a VideoPlayerError instance with code kVideoPlayerErrorKeysUnavailable = 5
 */
+(id)errorKeysUnavailable:(NSSet*) keys;

//------------------------------------------------------------------------------

/**
 * Creates a VideoPlayerError instance with code kVideoPlayerErrorInvalidVideoURL = 1
 */
+(id)errorAVAssetNotPlayable:(AVURLAsset*) assetURL;

//------------------------------------------------------------------------------

@end
