//
//  ViewController.h
//  SyncKitVideoSyncDemoApp
//
//  Created by Rajiv Ramdhany on 10/10/2016.
//  Copyright © 2016 Rajiv Ramdhany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyncKitDelegate/SyncKitConfigurator.h>
#import <DIALTVSelectionUIViews/DIALDeviceViewConstants.h>
#import <DIALDeviceDiscovery/DIALDeviceDiscovery.h>
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <VideoPlayer/VideoPlayerViewController.h>
#import <CSASynchroniser/CSASynchroniser.h>
#import <CIIProtocolClient/CIIProtocolClient.h>


@interface ViewController : UIViewController

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 *  A reference to the SynckitConfigurator singleton, this singleton holds the DIAL discovery state
 */
@property (readonly,strong, nonatomic) SynckitConfigurator* configurator;


/**
 *  A wrapper object for CSS-SyncKit library. It performs synchronisation of
 *  media objects with the selected TV using the
 */
@property (readonly,strong, nonatomic) Synchroniser* mediaSynchroniser;

/**
 *  An object to represent a timeline selector.  It is used to select a timeline
 *  signalled in the TV content
 */
@property (readonly,strong, nonatomic) TimelineOption* timelineSelector;

/**
 *  A media player object
 */
@property (readwrite, strong, nonatomic) MediaPlayerObject* mediaObject;


@end

