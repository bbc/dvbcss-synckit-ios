//
//  TimelineSynchroniser.h
//  TimelineSync
//
//  Created by Rajiv Ramdhany on 18/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ClockTimelines/ClockTimelines.h>

@class TimelineSynchroniser;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------
/**
 *  Timeline Synchroniser's state
 */
typedef NS_ENUM(NSUInteger, TSState) {
    /**
     *  Initialised state
     */
    TSInitalised,
    /**
     *  Connected to CSS-TS server
     */
    TSConnected,
    /**
     *  A successful response received after setup message was sent by TSClient
     */
    TSTimelineSetup,
    /**
     *  Timeline Clock is now in sync
     */
    TSSynced,
    /**
     *  WebSocket connection failure
     */
    TSConnectionFailure,
    /**
     *  Timeline Synhroniser stopped
     */
    TSStopped,
    /**
     *  Synchronisation Timeline is not available
     */
    TSTimelineUnavailable
};

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 *  Timeline Synchroniser state change notificationb
 */
FOUNDATION_EXPORT NSString* const  kTSStateChangeNotification;

//------------------------------------------------------------------------------
#pragma mark - TimelineSynchroniserDelegate
//------------------------------------------------------------------------------
/**
 *  Protocol implemented by a delegate of the TimelineSynchroniser class
 */
@protocol TimelineSynchroniserDelegate <NSObject>

/**
 *  Callback method reporting a change in state of the TimelineSynchroniser object.
 *
 *  @param ts    the TimelineSynchroniser instance
 *  @param state a TSState value
 */
- (void) ts:(TimelineSynchroniser*) ts DidChangeState:(TSState) state;


//------------------------------------------------------------------------------
@end


//------------------------------------------------------------------------------
#pragma mark - MWLogDebug(@"TSClient object created");
//------------------------------------------------------------------------------

/**
 *  A timeline synchroniser class. This will try to synchronise a programme timeline via timeline progress
 *  updates reported via the DVB-CSS TS protocol. The programme timeline is represented as a CorrelatedClock with
 *  parent clock as the WallClock. An example of this timeline is a PTS ticks timeline that a CSS-TV playing a
 *  broadcast MPEG2 Transport Stream can report progress on. 
 
 *  A Control Timestamp represents a new correlation
 *  for the programme timeline: {WallClock time, Content time, speed}.
 *
 *
 *  Please note that TimelineSynchroniser is not a singleton. It is perfectly possible to have multiple 
 *  TimelineSynchroniser instances, each synchronising a different programme (e.g. programmes with ads, 
 *  interstitials)
 */
@interface TimelineSynchroniser : NSObject


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  A DVB-CSS TV's estimated timeline. A CorrelatedClock object is provided by another party representing a timeline. This is the timeline that will be synchronised with a TV's timeline using DVB-CSS TS protocol.
 */
@property (nonatomic, weak, readonly) CorrelatedClock *cssTVTimeline;

/**
 *  A string specifying the type of timeline to be selected e.g. "urn:dvb:css:timeline:pts"
 */
@property (nonatomic, readonly) NSString *timelineSelector;

/**
 *  Id of the content currently played on the DVB-CSS TV
 */
@property (nonatomic, readonly) NSString* contentId;

/**
 *  Is the cssTVTimeline currently synchronised?
 */
@property (nonatomic, readonly) BOOL isSynced;

/**
 *  The DVB-CSS TV Tineline Synchronisation protocol's endpoint.
 */
@property (nonatomic, readonly) NSString* tsEndpointURL;


/**
 *  An offset in milliseconds to be added to the received correlation's wallclock timestamp. It can be positive or negative.
 */
@property (nonatomic,readwrite) NSTimeInterval offset;


/**
 *  Send notifications?
 */
@property (nonatomic, readonly) BOOL notifyObservers;

/**
 *  Timeline synchroniser state
 */
@property (nonatomic, readonly) TSState state;


/**
 *  Timeline synchroniser delegate
 */
@property (nonatomic) id<TimelineSynchroniserDelegate> delegate;


//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------

/**
 *  TimelineSynchroniser factory method
 *
 *  @param timeline    the CorrelatedClock object that will be synchronised to the timeline position and speed reported by the TV
 *  @param timelineSel the timeline type to be selected
 *  @param content_id  the content
 *  @param ts_endpoint string for DVB-CSS TS server endpoint URL
 *
 *  @return a TimelineSynchroniser instance
 */
+ (instancetype) TimelineSynchroniserWithTimeline:(CorrelatedClock*) timeline
                                 TimelineSelector:(NSString*) timelineSel
                                          Content:(NSString*) content_id
                                              URL:(NSString*) ts_endpoint;


/**
 *  TimelineSynchroniser factory method
 *
 *  @param timeline    the CorrelatedClock object that will be synchronised to the timeline position and speed reported by the TV
 *  @param timelineSel the timeline type to be selected
 *  @param content_id  the content
 *  @param ts_endpoint string for DVB-CSS TS server endpoint URL
 *  @param offset      an offset to be added to the 
 *
 *  @return a TimelineSynchroniser instance
 */
+ (instancetype) TimelineSynchroniserWithTimeline:(CorrelatedClock*) timeline
                                 TimelineSelector:(NSString*) timelineSel
                                          Content:(NSString*) content_id
                                              URL:(NSString*) ts_endpoint
                                           Offset:(NSTimeInterval) offset;

//------------------------------------------------------------------------------
#pragma mark - control methods
//------------------------------------------------------------------------------

/**
 *  Start the timeline sync
 */
- (void) start;

/**
 *  Stop the timeline sync, close open connections and clean up
 */
- (void) stop;


//------------------------------------------------------------------------------
#pragma mark - Notify Observers
//------------------------------------------------------------------------------


/**
 add an observer for clock state changes. Uses Notification design pattern in Cocoa.
 */
- (void) addObserver:(id) notificationObserver selection:(SEL) notificationSelector name:(NSString *) notificationName object:(id) objectOfInterest;

//------------------------------------------------------------------------------

/**
 remove clock observer
 */
- (void) removeObserver:(id) notificationObserver;


//------------------------------------------------------------------------------


/**
 notify observers of clock state changes
 */
- (void) notifyObservers:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;

@end

//------------------------------------------------------------------------------

