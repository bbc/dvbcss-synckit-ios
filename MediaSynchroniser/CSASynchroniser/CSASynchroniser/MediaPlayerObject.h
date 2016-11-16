//
//  MediaPlayerObject.h
//  CSASynchroniser
//
//  Created by Rajiv Ramdhany on 24/05/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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
#import <ClockTimelines/ClockTimelines.h>


/**
 *  An object encapsulating a media player instance, the media URL and a correlation for mapping the Synchronisation Timeline to the media timeline.
 */
@interface MediaPlayerObject : NSObject

/**
 *  A VideoPlayerViewController, AudioPlayer or UIWebview instance with the media loaded.
 */
@property (nonatomic, strong) id mediaPlayer;

@property (nonatomic) NSString* mediaURL;

@property (nonatomic) Correlation correlation;

@property (strong, nonatomic) NSString *mediaTitle;
@property (strong, nonatomic) NSString *mediaMIMEType;
@property (strong, nonatomic) NSNumber *priority;
@property (strong, nonatomic) NSNumber *startTime;
@property (strong, nonatomic) NSNumber *playDuration;


+ (instancetype) mediaPlayerObjectWith:(id) player
                              MediaURL:(NSString*) url
                           Correlation:(Correlation) corel;

- (instancetype) initMediaPlayerObjectWith:(id) player
                                  MediaURL:(NSString*) url
                               Correlation:(Correlation) corel;


- (BOOL) isEqual:(id)mediaplayerObject;


@end
