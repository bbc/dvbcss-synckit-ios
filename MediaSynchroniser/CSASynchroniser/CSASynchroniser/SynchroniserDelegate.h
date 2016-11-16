//
//  SynchroniserDelegate.h
//  Synchroniser
//
//  Created by Rajiv Ramdhany on 24/05/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//

#ifndef SynchroniserDelegate_h
#define SynchroniserDelegate_h


#import <AudioPlayerEngine/EZAudio.h>
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <VideoPlayer/VideoPlayerViewController.h>
#import <SyncController/SyncController.h>
#import <CIIProtocolClient/CIIProtocolClient.h>

@class Synchroniser;
//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

/**
 *  Synchroniser states
 *
 */
typedef NS_ENUM(NSUInteger, SynchroniserState)
{
    /**
     *  Initialised and CII protocol enabled
     */
    SynchroniserInitialised = 1,
    /**
     *  Sync enabled. CSS-WC and CSS-TS protocols running
     */
    SynchroniserSyncEnabled,
    /**
     *  Sync disabled.
     */
    SynchroniserSyncDisabled,
    /**
     *  Synchronisation timeline unavailable
     */
    SyncTimelineUnavailable,
    /**
     *  Sync timeline available
     */
    SyncTimelineAvailable,
    /**
     *  TV timeline is in paused state
     */
    SyncTimelinePaused,
    /**
     *  Sync accuracy threshold exceeded
     */
    SyncAccuracyExceedThreshold
};


//------------------------------------------------------------------------------
#pragma mark - SynchroniserDelegate
//------------------------------------------------------------------------------

/**
 *  The callback interface for a Synchroniser's delegate object.
 */
@protocol SynchroniserDelegate <NSObject>

/**
 *  Callback method to inform delegate about Synchroniser state changes
 *
 *  @param synchroniser the invoking Synchroniser instance
 *  @param state      a SynchroniserState state
 */
- (void) Synchroniser:(Synchroniser*) synchroniser DidChangeState:(SynchroniserState) state;

//------------------------------------------------------------------------------

/**
 *  Callback method to inform delegate about jitter (difference between expected and actual
 *  video player time position) afte resynchronisation of a video player. This callback
 *  is invoked after each resynchronisation procedure that causes a playback readjustment.
 *
 *  @param controller VideoPlayerSyncController object synchronising a video player
 *  @param status     one of VideoSyncControllerState enumerated states
 *  @param jitter     synchronisation jitter for the video player the controller controls
 *  @param error      error condition during synchronisation
 */
- (void) VideoSyncController:(VideoPlayerSyncController*) controller
                ReSyncStatus:(VideoSyncControllerState) status
                      Jitter:(NSTimeInterval) jitter
                   WithError:(SyncControllerError*) error;

//------------------------------------------------------------------------------

/**
 *  Callback method to inform delegate about jitter (difference between expected and actual
 *  audio player time position) after resynchronisation of a audio player. This callback
 *  is invoked after each resynchronisation procedure that causes a playback readjustment.
 *
 *  @param controller AudioSyncController object synchronising an audio player
 *  @param status     one of AudioSyncControllerState enumerated states
 *  @param jitter     synchronisation jitter for the audio player the controller controls
 *  @param error      error condition during synchronisation
 */
- (void) AudioSyncController:(AudioSyncController*) controller
                ReSyncStatus:(AudioSyncControllerState) status
                      Jitter:(NSTimeInterval) jitter
                   WithError:(SyncControllerError*) error;

//------------------------------------------------------------------------------

/**
 *  Callback reporting time since the start of the TV programme.
 *
 *  @param synchroniser the synchroniser object carrying out DVB-CSS synchronisation
 *  @param time         time in seconds since the start of the TV programme
 *  @param error        error bounds on this time reading
 */
- (void) Synchroniser:(Synchroniser*) synchroniser CurrentTime:(NSTimeInterval) time Error:(NSTimeInterval) error;

//------------------------------------------------------------------------------


/**
 *   Callback reporting the current synchronisation accuracy. This method is called back every 2 seconds.
 *   For the latest synchronisation accuracy reading, read this class's error property.
 *
 *  @param synchroniser the synchroniser object carrying out DVB-CSS synchronisation
 *  @param error        error bounds from the synchronisation process
 */
- (void) Synchroniser:(Synchroniser*) synchroniser SyncAccuracy:(NSTimeInterval) error;

//------------------------------------------------------------------------------


/**
 *  Reports new or updated Content Id Information from the TV when received through the CSS-CI protocol.
 *  The Content Id Information object contains a content identifier for the TV programme, the MRS URL,
 *  the CSS-WC server endpoint URL, the CSS-TS server endpoint URL, the presentation status of the TV
 *  and a list of timelines currently available at the TV for synchronisation.
 *
 *  @param synchroniser     the synchroniser object overseeing DVB-CSS synchronisation
 *  @param cii             an object encapsulating Content Id and Information (CII)
 *  @param cii_change_mask a bit mask showing which properties has changed.
 */
- (void) Synchroniser: (Synchroniser*) synchroniser NewContentInfoAvailable:(CII*) cii ChangeMask:(CIIChangeStatus) cii_change_mask;

//------------------------------------------------------------------------------

/**
 *  A convenience method to report only ContentId changes.
 *
 *  @param synchroniser the synchroniser object overseeing DVB-CSS synchronisation
 *  @param contentId    a Content Identifier for the content played by the TV
 */
- (void) Synchroniser: (Synchroniser*) synchroniser ContentIdDidChange:(NSString*) contentId;

//------------------------------------------------------------------------------





@end

#endif /* SynchroniserDelegate_h */
