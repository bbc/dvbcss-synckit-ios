//
//  Synchroniser.h
//  CSASynchroniser
//
//  Created by Rajiv Ramdhany on 23/05/2016.
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
#import <WallClockClient/WallClockClient.h>
#import <ClockTimelines/ClockTimelines.h>
#import <TimelineSync/TimelineSync.h>
#import <AudioPlayerEngine/EZAudio.h>
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <VideoPlayer/VideoPlayerViewController.h>
#import <SyncController/SyncController.h>
#import <CIIProtocolClient/CIIProtocolClient.h>

#import "SynchroniserDelegate.h"
#import "MediaPlayerObject.h"

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

/**
 *  Resynchronisation interval
 */
FOUNDATION_EXPORT NSTimeInterval const kDefaultResyncInterval;        // seconds

/**
 *  Video callibration offset
 */
FOUNDATION_EXPORT NSTimeInterval const kVideoCallibrationOffset;      // milliseconds

/**
 *  AV media audio track callibration offset
 */
FOUNDATION_EXPORT NSTimeInterval const kVideoSoundCallibrationOffset; // milliseconds

/**
 *  Audio callibration offset
 */
FOUNDATION_EXPORT NSTimeInterval const kAudioCallibrationOffset;      // milliseconds

/**
 *  Other media callibration offset
 */
FOUNDATION_EXPORT NSTimeInterval const kWebCallibrationOffset;      // milliseconds

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Synchroniser state change notification
 */
FOUNDATION_EXPORT NSString* const  kSynchroniserStateNotification;

/**
 *  SyncAccuracy threshold exceeded notification
 */
FOUNDATION_EXPORT NSString* const  kSynchroniserSyncAccuracyNotification;

/**
 *  Synchroniser content information change notification (new content id or timelines available for sync)
 */
FOUNDATION_EXPORT NSString* const  kSynchroniserNewContentIdNotification;


FOUNDATION_EXPORT NSString* const  kSynchroniserSyncTimelinesAvailableNotification;



//------------------------------------------------------------------------------
#pragma mark - Synchroniser
//------------------------------------------------------------------------------
/**
 *  A convenience DVB-CSS media synchroniser for Companion Screen Applications. A
 *  Synchroniser object is a singleton that will accept media players (each playing a media object)
 *  or web views to synchronise against a discovered TV running DVB-CSS set of Companion
 *  Synchronisation protocols. 
 *
 *  See README.md for usage explanation.
 */
@interface Synchroniser : NSObject <TimelineSynchroniserDelegate, SyncControllerDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------


/**
 *  The contentId reported by the TV via CSS-CII protocol. This property is updated before
 *  a kSynchroniserStateNotification with 
 */
@property(nonatomic, readonly) NSString            *contentId;

/**
 *  The status of the ContentId as defined in DVB-CSS specifications
 */
@property (nonatomic, readonly) NSString*         contentIdStatus;
/**
 *  TV content's presentation status e.g. final, or transitioning to another programme
 */
@property (nonatomic, readonly) NSString*         presentationStatus;

/**
 * Media timelines supported by the TV for synchronisation.
 */
@property (nonatomic, readonly) NSArray               *availableTimelines;

/**
 *  Material Resolution Service URL
 */
@property (nonatomic, readonly) NSString           *MRS_URL;

/**
 *  The selected master device's CSS-WC server endpoint
 */
@property (nonatomic, readonly) NSString           *WC_URL;

/**
 *  The selected master device's CSS-TS server endpoint
 */
@property (nonatomic, readonly) NSString           *TS_URL;

/**
 *  A local WallClock that is kept synchronised with the TV's wallclock
 */
@property (nonatomic, readonly) TunableClock           *wallclock;


/**
 *  The companion's copy of the Synchronisation Timeline (for example, the TV's timeline signalled in the broadcast)
 *  For a PTS timeline, selector = "urn:dvb:css:timeline:pts", tickrate =90000
 */
@property (nonatomic, readonly) CorrelatedClock        *syncTimeline;


/**
 *  An offset to add to the time on the synchronisation timeline
 */
@property (nonatomic, readwrite) NSTimeInterval        syncTimelineOffset;


/**
 *  The current synchronisation error on the timeline synchronisation
 */
@property (nonatomic, readonly) NSTimeInterval          error;


/**
 *  Media synchroniser delegate
 */
@property (nonatomic, readwrite) id<SynchroniserDelegate> delegate;

/**
 *  Current media synchroniser state
 */
@property (nonatomic, readonly) SynchroniserState          state;


/**
 *  Set YES to enable Status reports via NSNotifications
 */
@property (nonatomic, readwrite) BOOL                       sendNotifications;

/**
 *  Synchronisation accuracy threshold
 */
@property (nonatomic, readwrite) NSTimeInterval             syncThreshold;



//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------

/**
 *  Create a singleton instance of a Synchroniser
 *
 *  @return Synchroniser instance
 */
+(instancetype) getInstance;



//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------


/**
 *  Initialiser. On initialisation, the Synchroniser connects to the CSS-CII endpoint <code>cii_service_url</code> to
 *  receive CII messages containing contentId, CSS-WC URL, CSS-TS-URL, available-timeine information.
 *
 *  @param cii_service_url   interdevice synchronisation URL
 *  @param app2app_url         app2app server URL
 *  @param timeline_properties properties of the timeline to select for synchronisation
 *
 *  @return initialised Synchroniser instance
 */
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                           TimelineSelector:(TimelineOption*) timeline_properties;

//------------------------------------------------------------------------------

/**
 *  Initialiser. On initialisation, the Synchroniser connects to the CSS-CII endpoint <code>cii_service_url</code> to
 *  receive CII messages containing contentId, CSS-WC URL, CSS-TS-URL, available-timeine information.

 *
 *  @param cii_service_url   interdevice synchronisation URL
 *  @param app2app_url         app2app server URL
 *  @param timeline_properties properties of the timeline to select for synchronisation
 *  @param delegate            a SynchroniserDelegate delegate object
 *
 *  @return initialised Synchroniser instance
 */
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                           TimelineSelector:(TimelineOption*) timeline_properties
                                   Delegate:(id<SynchroniserDelegate>) delegate;
//------------------------------------------------------------------------------

/**
 *  Initialiser
 *
 *  @param cii_service_url   interdevice synchronisation URL
 *  @param app2app_url         app2app server URL
 *  @param media_object_list list of media players/webviews with loaded media objects and their correlations
                             mapping timestamps from synchronisation timeline to media object's timeline
 *  @param timeline_properties properties of the timeline to select for synchronisation
 *
 *  @return initialised Synchroniser instance
 */
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                               MediaObjects:(NSArray*) media_object_list
                           TimelineSelector:(TimelineOption*) timeline_properties;

//------------------------------------------------------------------------------

/**
 *  Initialiser. On initialisation, the Synchroniser connects to the CSS-CII endpoint <code>cii_service_url</code> to
 *  receive CII messages containing contentId, CSS-WC URL, CSS-TS-URL, available-timeine information.

 *
 *  @param cii_service_url   interdevice synchronisation URL
 *  @param media_object_list list of media players/webviews with loaded media objects and their correlations
 mapping timestamps from synchronisation timeline to media object's timeline
 *  @param timeline_properties properties of the timeline to select for synchronisation
 *  @param delegate          a delegate to receive callback notifications during synchronisation
 *
 *  @return initialised Synchroniser instance */
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                               MediaObjects:(NSArray*) media_object_list
                           TimelineSelector:(TimelineOption*) timeline_properties
                                   Delegate:(id<SynchroniserDelegate>) delegate;

//------------------------------------------------------------------------------

/**
 *  Initialiser. On initialisation, the Synchroniser connects to the CSS-CII endpoint <code>cii_service_url</code> to
 *  receive CII messages containing contentId, CSS-WC URL, CSS-TS-URL, available-timeine information.

 *
 *  @param cii_service_url   interdevice synchronisation URL
 *  @param App2App_URL       the HbbTV 2.0 app2app URL
 *  @param media_object_list list of media players/webviews with loaded media objects and their correlations
 mapping timestamps from synchronisation timeline to media object's timeline
 *  @param timeline_properties properties of the timeline to select for synchronisation
 *  @param delegate          a delegate to receive callback notifications during synchronisation
 *
 *  @return initialised Synchroniser instance
 */
- (instancetype) initWithInterDeviceSyncURL:(NSString*) cii_service_url
                                 App2AppURL:(NSString*) app2app_url
                               MediaObjects:(NSArray*) media_object_list
                           TimelineSelector:(TimelineOption*) timeline_properties
                                   Delegate:(id<SynchroniserDelegate>) delegate;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Add a media object to be synchronised. It creates a SyncController for
 *  the media object
 *
 *  @param media_obj a media player, media item and its correlation
 *
 *  @return true if the sync controller for this media object was created
 *  and started.
 */
- (BOOL) addMediaObject:(MediaPlayerObject*) media_obj;

//------------------------------------------------------------------------------

/**
 *  Remove media object from synchroniser. The SyncController for the
 *  media object is stopped and destroyed.
 *
 *  @param media_obj a MediaPlayerObject instance
 *
 *  @return true if the sync controller for this media object was stopped.
 */
- (BOOL) removeMediaObject:(MediaPlayerObject*) media_obj;

//------------------------------------------------------------------------------

/**
 *  Enable synchronisation by instantiating DVB-CSS protocol endpoints and protocol handlers. 
 *
 *  @description The Synchroniser first initiates WallClock synchronisation. When the WallClock is sync'ed
 *  it performs timeline synchronisation to build an estimate of the TV timeline. Once a TV timeline is available locally,
 *  the Synchroniser creates SyncController for every media player registered with it. The SyncController uses a Correlation Timestamp
 *  to estimate the expected media timeline and makes the media player adhere to this timeline.
 *
 *  @param syncThreshold a target sync accuracy. If this threshold is exceeded, a kSynchroniserSyncAccuracyNotification notification is emitted by the Synchroniser
 *  @param error         an error object if something went wrong; else nil is returned
 */
- (void) enableSynchronisation:(float) syncThreshold Error:(NSError** ) error;

//------------------------------------------------------------------------------


/**
 * Stops the synchronisation process. For every media object registered with the Synchroniser, this operation stops and destroys the SyncController. It then stops 
 * the Timeline Synchronisation by destroying the TimelineSynchroniser and the SynchronisationTimeline clock (also called TVTimeline).
 */
- (void) disableSynchronisation:(NSError**) error;

//------------------------------------------------------------------------------






@end
