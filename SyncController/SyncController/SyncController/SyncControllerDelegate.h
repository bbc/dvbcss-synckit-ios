//
//  SyncControllerDelegate.h
//  SyncController
//
//  Created by Rajiv Ramdhany on 24/05/2016.
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

#ifndef SyncControllerDelegate_h
#define SyncControllerDelegate_h

//------------------------------------------------------------------------------
#pragma mark - SyncControllerDelegate protocool
//------------------------------------------------------------------------------
@protocol SyncControllerDelegate <NSObject>

/**
 *  Callback method to inform delegate about SyncController's state changes
 *
 *  @param controller the invoking SyncController instance
 *  @param state      a SyncControllerState state, an enumerated value
 */
- (void) SyncController:(id) controller DidChangeState:(NSUInteger) state;

//------------------------------------------------------------------------------

@optional
/**
 *  Callback method to inform delegate about jitter (difference between expected and actual
 *  media player time position) after a resynchronisation.
 *
 *  @discussion: this method is invoked every 'syncInterval' seconds or after every observed
 *  change in 'expectedTimeline'.
 *
 *
 *  @param controller the invoking SyncController instance
 *  @param jitter     time interval in seconds
 *  @param error      resynchronisation error. If error !=nil, jitter will be zero or less.
 */
- (void) SyncController:(id) controller
           ReSyncStatus:(NSUInteger) status
                 Jitter:(NSTimeInterval) jitter
              WithError:(SyncControllerError*) error;


//------------------------------------------------------------------------------
@end

#endif /* SyncControllerDelegate_h */
