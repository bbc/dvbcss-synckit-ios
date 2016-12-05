//
//  MediaPlayerObject.m
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

#import "MediaPlayerObject.h"

@implementation MediaPlayerObject

+ (instancetype) mediaPlayerObjectWith:(id) player
                                 MediaURL:(NSString*) url
                           Correlation:(Correlation) corel
{
    return [[MediaPlayerObject alloc] initMediaPlayerObjectWith:player MediaURL:url Correlation:corel];
    
}

- (instancetype) initMediaPlayerObjectWith:(id) player
                                  MediaURL:(NSString*) url
                               Correlation:(Correlation) corel
{
    self = [super init];
    
    if (self != nil)
    {
        _mediaPlayer = player;
        _mediaURL = url;
        _correlation = corel;
    }
    
    return self;
}



- (BOOL) isEqual:(id)object
{
    
    BOOL comparator = YES;
    
    
    if ([object class] == [MediaPlayerObject class])
    {
        
        MediaPlayerObject* mediaObject = (MediaPlayerObject*) object;

        comparator = comparator && ([mediaObject.mediaURL compare:self.mediaURL options:NSCaseInsensitiveSearch] == NSOrderedSame);
               
        comparator = comparator && (mediaObject.mediaPlayer == self.mediaPlayer);

        return comparator;
  
    }else
        return NO;
    
    
}


@end
