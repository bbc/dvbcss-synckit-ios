//
//  VideoPlayerError.m
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

#import "VideoPlayerError.h"


NSString* const VideoPlayerErrorDomain = @"VideoPlayerErrorDomain";
NSString* const kVideoPlayerInvalidAsset = @"kVideoPlayerInvalidAsset";
NSString* const kVideoPlayerBadServerResponse = @"kVideoPlayerBadServerResponse";
NSString* const kVideoPlayerBadFormat = @"kVideoPlayerBadFormat";
NSString* const kVideoPlayerMediaKeysNotLoaded = @"kVideoPlayerMediaKeysNotLoaded";
//------------------------------------------------------------------------------
#pragma mark - VideoPlayerViewController implementation
//------------------------------------------------------------------------------

@implementation VideoPlayerError
{
    
}

//------------------------------------------------------------------------------
#pragma mark - factory methods
//------------------------------------------------------------------------------


+(id)errorInvalidVideoURL:(NSString*) url
{
    return [VideoPlayerError errorWithDomain:VideoPlayerErrorDomain
                                        code:kVideoPlayerErrorInvalidVideoURL
                                    userInfo:@{NSLocalizedDescriptionKey:@"Invalid video URL.", kVideoPlayerInvalidAsset:url}];
}

//------------------------------------------------------------------------------

+(id)errorBadResponse:(NSString*) response
{
    return [VideoPlayerError errorWithDomain:VideoPlayerErrorDomain
                                        code:kVideoPlayerErrorBadResponse
                                    userInfo:@{NSLocalizedDescriptionKey:@"Bad response from server.", kVideoPlayerBadServerResponse:response}];
}

//------------------------------------------------------------------------------

+(id)errorUnsupportedFormat:(NSString*) format
{
    return [VideoPlayerError errorWithDomain:VideoPlayerErrorDomain
                                        code:kVideoPlayerErrorUnsupportedFormat
                                    userInfo:@{NSLocalizedDescriptionKey:@"Unsupported video format.", kVideoPlayerBadFormat:format}];
}

//------------------------------------------------------------------------------

+(id)errorSeekingNotPossible
{
    return [VideoPlayerError errorWithDomain:VideoPlayerErrorDomain
                                        code:kVideoPlayerErrorSeekingNotPossible
                                    userInfo:@{NSLocalizedDescriptionKey:@"Seeking is not supported with this format"}];
}

//------------------------------------------------------------------------------

+(id)errorKeysUnavailable:(NSSet*) keys;
{
    return [VideoPlayerError errorWithDomain:VideoPlayerErrorDomain
                                        code:kVideoPlayerErrorKeysUnavailable
                                    userInfo:@{NSLocalizedDescriptionKey:@"Media keys not available", kVideoPlayerMediaKeysNotLoaded:[keys allObjects]}];
}

//------------------------------------------------------------------------------
+(id)errorAVAssetNotPlayable:(AVURLAsset*) assetURL
{
    return [VideoPlayerError errorWithDomain:VideoPlayerErrorDomain
                                        code:kVideoPlayerAVAssetNotPlayable
                                    userInfo:@{NSLocalizedDescriptionKey:@"AV asset is not playable", kVideoPlayerInvalidAsset:assetURL}];
}

//------------------------------------------------------------------------------


@end
