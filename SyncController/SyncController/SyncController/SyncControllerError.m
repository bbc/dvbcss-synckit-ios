//
//  SyncControllerError.m
//  VideoSyncController
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

#import "SyncControllerError.h"


//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

NSString* const SyncControllerErrorDomain               = @"SyncControllerErrorDomain";
NSString* const kSyncControllerNoSyncTimeline           = @"kSyncControllerNoSyncTimeline";
NSString* const kSyncControllerSyncTimelineUnavailable  = @"kSyncControllerSyncTimelineUnavailable";
NSString* const kSyncControllerMediaNotSeekable         = @"kSyncControllerMediaNotSeekable";
NSString* const kSyncControllerMediaRangeNotLoaded      = @"kSyncControllerMediaRangeNotLoaded";
NSString* const kSyncControllerPlayerRateError          = @"kSyncControllerPlayerRateError";


//------------------------------------------------------------------------------
#pragma mark - SyncControllerError implementation
//------------------------------------------------------------------------------


@implementation SyncControllerError

//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------


+(id)errorNoSyncTimeline
{
    return [SyncControllerError errorWithDomain:SyncControllerErrorDomain
                                        code:kSyncControllerErrorNoSyncTimeline
                                    userInfo:@{NSLocalizedDescriptionKey:@"No synchronisation timeline specified."}];
}

//------------------------------------------------------------------------------

+(id)errorSyncTimelineUnavailable: (CorrelatedClock*) timeline
{
    return [SyncControllerError errorWithDomain:SyncControllerErrorDomain
                                           code:kSyncControllerErrorSyncTimelineUnavailable
                                       userInfo:@{NSLocalizedDescriptionKey:@"Synchronisation timeline is not available.", kSyncControllerSyncTimelineUnavailable: timeline}];
}

//------------------------------------------------------------------------------

+(id)errorUnableToChangePlaybackPosition:(VideoPlayerViewController*) player
{
    return [SyncControllerError errorWithDomain:SyncControllerErrorDomain
                                           code:kSyncControllerErrorMediaNotSeekable
                                       userInfo:@{NSLocalizedDescriptionKey:@"Cannot change player's playback position. Media not seekable.", kSyncControllerMediaNotSeekable: player}];
}

//------------------------------------------------------------------------------

+(id)errorMediaRangeNotAvailable:(VideoPlayerViewController*) player
{
    
    return [SyncControllerError errorWithDomain:SyncControllerErrorDomain
                                           code:kSyncControllerErrorSeekRangeNotLoaded
                                       userInfo:@{NSLocalizedDescriptionKey:@"Media range to seek to is not loaded.", kSyncControllerMediaRangeNotLoaded: player}];
    
}

//------------------------------------------------------------------------------


+(id)errorUnabletoChangePlaybackRate
{
    return [SyncControllerError errorWithDomain:SyncControllerErrorDomain
                                           code:kSyncControllerErrorPlayerSetRateError
                                       userInfo:@{NSLocalizedDescriptionKey:@"Cannot not change player's playback rate."}];

}

//------------------------------------------------------------------------------


@end
