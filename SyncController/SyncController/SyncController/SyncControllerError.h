//
//  SyncControllerError.h
//  VideoSyncController
//
//  Created by Rajiv Ramdhany on 25/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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
#import <AVFoundation/AVFoundation.h>
#import <ClockTimelines/ClockTimelines.h>
#import <VideoPlayer/VideoPlayer.h>

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef NS_ENUM(int, kSyncControllerErrorTypes)
{
    kSyncControllerErrorNoSyncTimeline = 1,
    kSyncControllerErrorSyncTimelineUnavailable = 2,
    kSyncControllerErrorMediaNotSeekable = 3,
    kSyncControllerErrorSeekRangeNotLoaded = 4,
    kSyncControllerErrorPlayerSetRateError = 5
};


//------------------------------------------------------------------------------

/** The domain name used for the VideoPlayerError instances */
extern NSString* const SyncControllerErrorDomain;

extern NSString* const kSyncControllerNoSyncTimeline;
extern NSString* const kSyncControllerSyncTimelineUnavailable;
extern NSString* const kSyncControllerMediaNotSeekable;
extern NSString* const kSyncControllerPlayerRateError;
//------------------------------------------------------------------------------
#pragma mark - SyncControllerError
//------------------------------------------------------------------------------

/**
 *  Custom NSError subclass with shortcut methods for creating
 * the common SyncControllerError errors
 */
@interface SyncControllerError : NSError


//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------

/**
 * Creates a SyncControllerError instance with code kSyncControllerErrorNoSyncTimeline = 1
 */
+(id)errorNoSyncTimeline;

//------------------------------------------------------------------------------

/**
 * Creates a SyncControllerError instance with code kSyncControllerErrorSyncTimelineUnavailable = 2
 */
+(id)errorSyncTimelineUnavailable: (CorrelatedClock*) timeline;

//------------------------------------------------------------------------------

/**
 * Creates a SyncControllerError instance with code kSyncControllerErrorMediaNotSeekable = 3
 */
+(id)errorUnableToChangePlaybackPosition:(VideoPlayerViewController*) player;

//------------------------------------------------------------------------------

/**
 * Creates a SyncControllerError instance with code kSyncControllerErrorSeekRangeNotLoaded = 4
 */
+(id)errorMediaRangeNotAvailable:(VideoPlayerViewController*) player;

//------------------------------------------------------------------------------


/**
 * Creates a SyncControllerError instance with code kSyncControllerErrorPlayerSetRateError = 5
 */
+(id)errorUnabletoChangePlaybackRate;

//------------------------------------------------------------------------------




@end
