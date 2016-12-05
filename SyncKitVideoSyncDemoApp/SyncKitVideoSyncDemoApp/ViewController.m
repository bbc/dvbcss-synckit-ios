//
//  ViewController.m
//  SyncKitVideoSyncDemoApp
//
//  Created by Rajiv Ramdhany on 10/10/2016.
//  Copyright © 2016 Rajiv Ramdhany. All rights reserved.
//

#import "ViewController.h"
#import "F3BarGauge.h"
#import "AppDelegate.h"
#import <SimpleLogger/SimpleLogger.h>


//------------------------------------------------------------------------------
#pragma mark - Type declaration
//------------------------------------------------------------------------

typedef enum {
    Audio,
    Video,
    Web,
    Text,
    PDF,
    Image,
    Unsupported,
    
    MediaAssetTypeCount
}MediaAssetType;

//------------------------------------------------------------------------------
#pragma mark - Timelines constants
//------------------------------------------------------------------------------

NSString* const kCT_TimelineSelector = @"urn:dvb:css:timeline:ct";
int const kCT_UnitsPerTick = 1;
int const kCT_UnitsPerSecond = 48000;

//------------------------------------------------------------------------------

NSString* const kPTS_TimelineSelector = @"urn:dvb:css:timeline:pts";
int const kPTS_UnitsPerTick = 1;
int const kPTS_UnitsPerSecond = 90000;

//------------------------------------------------------------------------------

NSString* const kTEMI_TimelineSelector = @"urn:dvb:css:timeline:temi:1:128";
int const kTEMI_UnitsPerTick = 1;
int const kTEMI_UnitsPerSecond = 1000;

//------------------------------------------------------------------------------

NSString* const kSET_TimelineSelector = @"tag:rd.bbc.co.uk,2015-12-08:dvb:css:timeline:simple-elapsed-time:1000";
int const kSET_UnitsPerTick = 1;
int const kSET_UnitsPerSecond = 1000;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - synchronisation constants
//------------------------------------------------------------------------------


float const kSyncAccuracyThreshold = 10.0;

//------------------------------------------------------------------------------
#pragma mark - constants for Channel A companion video
//------------------------------------------------------------------------------

NSString* const kCompanion_Video_A = @"video_a";
NSString* const kCompanion_Video_A_type = @"mp4";
NSString* const kContentId_ChannelA = @"dvb://ffff.fffe.044d;03e9~20150331T1500Z--PT00H15M";
int const A_PTS_Timeline_Start_Pos = 900000;
int const A_TEMI_Timeline_Start_Pos = 0;
int const A_SET_Timeline_Start_Pos = 0;
int const Video_A_Timeline_Start_Pos = 0;

//------------------------------------------------------------------------------
#pragma mark - constants for Channel B companion video
//------------------------------------------------------------------------------

NSString* const kCompanion_Video_B = @"video_b";
NSString* const kCompanion_Video_B_type = @"mp4";
NSString* const kContentId_ChannelB = @"dvb://ffff.fffe.044e;07d1~20150331T1500Z--PT00H15M";
int const B_PTS_Timeline_Start_Pos = 7200000;
int const B_TEMI_Timeline_Start_Pos = 0;
int const B_SET_Timeline_Start_Pos = 0;
int const Video_B_Timeline_Start_Pos = 0;


//------------------------------------------------------------------------------
#pragma mark - constants for Channel C companion video
//------------------------------------------------------------------------------

NSString* const kCompanion_Video_C = @"video_c";
NSString* const kCompanion_Video_C_type = @"mp4";
NSString* const kContentId_ChannelC = @"dvb://ffff.fffe.044f;0bb9~20150331T1500Z--PT00H15M";
int const C_PTS_Timeline_Start_Pos = 1800000;
int const C_TEMI_Timeline_Start_Pos = 0;
int const C_SET_Timeline_Start_Pos = 0;
int const Video_C_Timeline_Start_Pos = 0;



//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - Interface extensions
//------------------------------------------------------------------------------

@interface ViewController () <SynchroniserDelegate, VideoPlayerDelegate>

//------------------------------------------------------------------------------
#pragma mark - access permissions redefinition
//------------------------------------------------------------------------------

@property (readwrite, nonatomic) SynckitConfigurator* configurator;
@property (readwrite, nonatomic) Synchroniser* mediaSynchroniser;

//------------------------------------------------------------------------------
#pragma mark - Object-scope Properties
//------------------------------------------------------------------------------

@property (strong, nonatomic) IBOutlet UIView *contentView;

/**
 *  Toolbar showing playback progress and
 */
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UILabel *playbackProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *materialTitleLabel;
@property (weak, nonatomic) IBOutlet F3BarGauge *dispersionBarGauge;
@property (weak, nonatomic) IBOutlet UILabel *dispersionLabel;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property BOOL lockNavBarAsHidden;
@property UIDeviceOrientation currentDeviceOrientation;

@property (weak, nonatomic) IBOutlet UIProgressView *videoProgressBar;

- (void) initialiseUI;


@end


//------------------------------------------------------------------------------
#pragma mark - ViewController implementation
//------------------------------------------------------------------------------

@implementation ViewController
{
    TimelineOption* pts_timeline;
    TimelineOption* temi_timeline;
    TimelineOption* set_timeline;
    TimelineOption* ct_timeline;
    
    DIALDevice* device;
    NSNull *nullObject;
    UIInterfaceOrientation _preferredOrientation;
    id temp;
}

//------------------------------------------------------------------------------
#pragma mark - UIViewController methods
//------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    nullObject = [NSNull null];
    
    [self initialiseUI];

    // create timeline description objects
    ct_timeline = [TimelineOption TimelineOptionWithSelector:kCT_TimelineSelector
                                                UnitsPerTick:kCT_UnitsPerTick
                                              UnitsPerSecond:kCT_UnitsPerSecond
                                                    Accuracy:0];
    
    set_timeline = [TimelineOption TimelineOptionWithSelector:kSET_TimelineSelector
                                                 UnitsPerTick:kSET_UnitsPerTick
                                               UnitsPerSecond:kSET_UnitsPerSecond
                                                     Accuracy:0];
    
    pts_timeline = [TimelineOption TimelineOptionWithSelector:kPTS_TimelineSelector
                                                 UnitsPerTick:kPTS_UnitsPerTick
                                               UnitsPerSecond:kPTS_UnitsPerSecond
                                                     Accuracy:0];
    
    temi_timeline = [TimelineOption TimelineOptionWithSelector:kTEMI_TimelineSelector
                                                  UnitsPerTick:kTEMI_UnitsPerTick
                                                UnitsPerSecond:kTEMI_UnitsPerSecond
                                                      Accuracy:0];
    // retrieve our selected TV device description object
    self.configurator = [SynckitConfigurator getInstance];
    device = self.configurator.currentDIALdevice;
    
    // create a companion screen synchroniser object, initialise and start it
    if (device){
        self.mediaSynchroniser = [Synchroniser getInstance];
        self.mediaSynchroniser = [self.mediaSynchroniser initWithInterDeviceSyncURL:device.HbbTV_InterDevSyncURL
                                                                         App2AppURL:device.HbbTV_App2AppURL
                                                                       MediaObjects:nil
                                                                   TimelineSelector:temi_timeline
                                                                           Delegate:self];
        
        // set the video callibration offset for video presentation (we are showing only videos in this app)
        // this offset can be changed when new media object types e.g. audio or web are loaded. Only one callibration offset can be set at a time with the synchroniser.
        // Adding multiple callibration offsets for different media object types is planned for the next iteration.
        self.mediaSynchroniser.syncTimelineOffset = kVideoCallibrationOffset;
        
        // enable sync for when media objects are added.
        [self.mediaSynchroniser enableSynchronisation:kSyncAccuracyThreshold
                                                Error:nil];
        
    }
}

//------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------
#pragma mark - private methods
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------


- (void)deviceDidRotate:(NSNotification *)notification
{
    self.currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (self.mediaObject)
    {
       if ([_mediaObject.mediaPlayer class] == [VideoPlayerViewController class])
        {
            
            VideoPlayerViewController *videoPlayer = (VideoPlayerViewController*) _mediaObject.mediaPlayer;
            
            CGRect frame = videoPlayer.videoPlayer.frame;
            
            frame.origin.x = self.view.bounds.origin.y;
            frame.origin.y = self.view.bounds.origin.x;
            frame.size.width = self.view.bounds.size.height;
            frame.size.height = self.view.bounds.size.width;
            
            [videoPlayer.videoPlayer setFrame:frame];
        }
    }
}


//------------------------------------------------------------------------------

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    
    self.toolbarView.hidden = !self.toolbarView.hidden;
}

//------------------------------------------------------------------------------

- (void) initialiseUI
{
    
    self.lockNavBarAsHidden = NO;
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
    
    // set up gesture recognisers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    // set material UILabel frame width
    CGRect frame = self.materialTitleLabel.frame;
    frame.size.width = self.toolbarView.frame.size.width - 10 -89 -58- 31;
    self.materialTitleLabel.frame = frame;
    
    // setup dispersion gauge bar
    self.dispersionBarGauge.numBars=10;
    self.dispersionBarGauge.warnThreshold=0.4;
    self.dispersionBarGauge.dangerThreshold=0.75;
    
    self.videoProgressBar.progress = 0.0;
    
    self.toolbarView.hidden = NO;
}


//------------------------------------------------------------------------------

- (BOOL) loadMediaObject:(MediaPlayerObject*) mediaObject Delegate:(id) delegate inView:(UIView*) parentView
{
    // create the player for the selected media object and position in view
    // player will be started when synchronisation timeline is available
    
     VideoPlayerViewController* videoplayer;
     __weak UIViewController<VideoPlayerDelegate> *weakVideoPlayerDelegate = delegate;
    
    videoplayer = [[VideoPlayerViewController alloc] initWithParentView:parentView
                                                               Delegate:weakVideoPlayerDelegate];
    videoplayer.videoURL = [ NSURL URLWithString:mediaObject.mediaURL];
    videoplayer.shouldLoop = YES;
    
    mediaObject.mediaPlayer = videoplayer;
    
    
    if (_mediaSynchroniser)
    {
        [_mediaSynchroniser addMediaObject:_mediaObject];
    }
    
    [self.toolbarView setHidden:NO];
    [self.view bringSubviewToFront:self.toolbarView];
    
    return YES;
    
}

//------------------------------------------------------------------------------


- (void) unloadMediaObject
{
    if (_mediaObject)
    {
        // remove media object from CSSynchroniser instance
        if (_mediaSynchroniser)
        {
            [_mediaSynchroniser removeMediaObject:_mediaObject];
        }
        
        if ([_mediaObject.mediaPlayer class] == [VideoPlayerViewController class])
        {
            
            MWLogDebug(@"ViewController.unloadCurrentContent - removing video player.");
            VideoPlayerViewController *videoPlayer = (VideoPlayerViewController*) _mediaObject.mediaPlayer;
            
            [videoPlayer stopAndRemoveFromParentView];
            
            videoPlayer.delegate = nil;
            videoPlayer =  nil;
            temp = _mediaObject.mediaPlayer; // keep video object for a little while to wait for cleanup
            _mediaObject.mediaPlayer =  nil;
            
            
        }
        
        _mediaObject = nil;
        
    }
}






//------------------------------------------------------------------------------
#pragma mark - SynchroniserDelegate methods
//------------------------------------------------------------------------------

- (void) Synchroniser:(Synchroniser*) synchroniser DidChangeState:(SynchroniserState) state
{
    
    
    
    
}

//------------------------------------------------------------------------------

- (void) VideoSyncController:(VideoPlayerSyncController*) controller
                ReSyncStatus:(VideoSyncControllerState) status
                      Jitter:(NSTimeInterval) jitter
                   WithError:(SyncControllerError*) error
{
    
}

//------------------------------------------------------------------------------




- (void) AudioSyncController:(AudioSyncController*) controller
                ReSyncStatus:(AudioSyncControllerState) status
                      Jitter:(NSTimeInterval) jitter
                   WithError:(SyncControllerError*) error
{
    
    
    
}


//------------------------------------------------------------------------------

- (void) Synchroniser:(Synchroniser*) synchroniser CurrentTime:(NSTimeInterval) time Error:(NSTimeInterval) error
{
    
}

//------------------------------------------------------------------------------

- (void) Synchroniser:(Synchroniser*) synchroniser SyncAccuracy:(NSTimeInterval) error
{
    
    MWLogDebug(@"ViewController.Synchroniser SyncAccuracy: %f", error);
    
    
}

//------------------------------------------------------------------------------


- (void) Synchroniser: (Synchroniser*) synchroniser NewContentInfoAvailable:(CII*) cii ChangeMask:(CIIChangeStatus) cii_change_mask
{
    
    // we have received Content Id Information from the TV
    // if content Id is null,
    //      we unload all the players
    // else
    //      resolve content Id to companion assets and correlation
    //      load media players for assets
    
    
    if ((cii_change_mask & ContentIdChanged) || (cii_change_mask & NewCIIReceived))
    {
        if  ((cii.contentId == nil) || ([cii.contentId class] == [NSNull class]))
        {
            MWLogDebug(@"ViewController.NewContentInfoAvailable: Content Id is null");
            
            [self unloadMediaObject];
            
            // unhide the default content
            [self.view addSubview:_placeholderView];
            [_placeholderView setHidden:NO];
            
        }else
        {
             MWLogDebug(@"ViewController.NewContentInfoAvailable: Content Id is %@", cii.contentId);
            NSURL *mediaFileURL = nil;;
            
            [self unloadMediaObject];
            
            // unhide the default content
            [self.view addSubview:_placeholderView];
            [_placeholderView setHidden:NO];
            
            if ([cii.contentId caseInsensitiveCompare:kContentId_ChannelA] == NSOrderedSame)
            {
                // hide the default view
                [_placeholderView removeFromSuperview ];
                [_placeholderView setHidden:YES];

                // create a MediaPlayerObject
                MediaPlayerObject* mediaObj = [[MediaPlayerObject alloc] init];
                mediaFileURL = [[NSBundle mainBundle] URLForResource:kCompanion_Video_A withExtension:kCompanion_Video_A_type];
                
                if (mediaFileURL){
                    
                    mediaObj.mediaURL =  [mediaFileURL absoluteString];
                    
                    // create correlations for the timeline we have initialised our mediaSynchroniser object with for synchronisation
                    Correlation TEMI_Timeline_corel = [CorrelationFactory create:A_TEMI_Timeline_Start_Pos Correlation: Video_A_Timeline_Start_Pos];
                    
                    mediaObj.correlation = TEMI_Timeline_corel;
                    mediaObj.mediaTitle = @"companion video A";
                    mediaObj.mediaMIMEType = @"video/mp4";
                    mediaObj.priority = [NSNumber numberWithInt:1];
                    
                    [self.materialTitleLabel setText:mediaObj.mediaTitle];
                    
                    self.mediaObject = mediaObj;
                    
                    // load the media object and add it to our synchroniser
                    [self loadMediaObject:_mediaObject Delegate:self inView:self.view];
                }else
                {
                    // unhide the default content
                    [self.view addSubview:_placeholderView];
                    [_placeholderView setHidden:NO];
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:@"Companion asset not found"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }

            }else if ([cii.contentId caseInsensitiveCompare:kContentId_ChannelB] == NSOrderedSame)
            {
                // hide the default view
                [_placeholderView removeFromSuperview ];
                [_placeholderView setHidden:YES];
                
                // create a MediaPlayerObject
                MediaPlayerObject* mediaObj = [[MediaPlayerObject alloc] init];
                mediaFileURL = [[NSBundle mainBundle] URLForResource:kCompanion_Video_B withExtension:kCompanion_Video_B_type];
                
                if (mediaFileURL){
                
                    mediaObj.mediaURL =  [mediaFileURL absoluteString];
                    
                    // create correlations for the timeline we have initialised our mediaSynchroniser object with for synchronisation
                    Correlation TEMI_Timeline_corel = [CorrelationFactory create:B_TEMI_Timeline_Start_Pos Correlation: Video_B_Timeline_Start_Pos];
                    
                    mediaObj.correlation = TEMI_Timeline_corel;
                    mediaObj.mediaTitle = @"companion video B";
                    mediaObj.mediaMIMEType = @"video/mp4";
                    mediaObj.priority = [NSNumber numberWithInt:1];
                    
                    [self.materialTitleLabel setText:mediaObj.mediaTitle];
                    
                    self.mediaObject = mediaObj;
                    
                    // load the media object and add it to our synchroniser
                    [self loadMediaObject:_mediaObject Delegate:self inView:self.view];
                }else
                {
                    // unhide the default content
                    [self.view addSubview:_placeholderView];
                    [_placeholderView setHidden:NO];
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:@"Companion asset not found"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }

                
            }else if ([cii.contentId caseInsensitiveCompare:kContentId_ChannelC] == NSOrderedSame)
            {
                // hide the default view
                [_placeholderView removeFromSuperview ];
                [_placeholderView setHidden:YES];
                
                // create a MediaPlayerObject
                MediaPlayerObject* mediaObj = [[MediaPlayerObject alloc] init];
                mediaFileURL = [[NSBundle mainBundle] URLForResource:kCompanion_Video_C withExtension:kCompanion_Video_C_type];
                
                if (mediaFileURL){
                    
                    mediaObj.mediaURL =  [mediaFileURL absoluteString];
                    
                    // create correlations for the timeline we have initialised our mediaSynchroniser object with for synchronisation
                    Correlation TEMI_Timeline_corel = [CorrelationFactory create:C_TEMI_Timeline_Start_Pos Correlation: Video_C_Timeline_Start_Pos];
                    
                    mediaObj.correlation = TEMI_Timeline_corel;
                    mediaObj.mediaTitle = @"companion video C";
                    mediaObj.mediaMIMEType = @"video/mp4";
                    mediaObj.priority = [NSNumber numberWithInt:1];
                    
                    [self.materialTitleLabel setText:mediaObj.mediaTitle];
                    
                    self.mediaObject = mediaObj;
                    
                    // load the media object and add it to our synchroniser
                    [self loadMediaObject:_mediaObject Delegate:self inView:self.view];
                }else
                {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:@"Companion asset not found"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }
     }
}




//------------------------------------------------------------------------------


- (void) Synchroniser: (Synchroniser*) synchroniser ContentIdDidChange:(NSString*) contentId
{
    // not used
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - VideoPlayerDelegate methods
//------------------------------------------------------------------------------


-(void) VideoPlayer:(VideoPlayerView *) videoplayer
              State:(VideoPlayerState) state{
    
    if (state == VideoPlayerStateReadyToPlay)
    {
        VideoPlayerViewController *videoPlayerVC = (VideoPlayerViewController*) _mediaObject.mediaPlayer;
        [videoPlayerVC play];
        
    }
    //[self.view bringSubviewToFront:self.buttonBarView];
    
}

//------------------------------------------------------------------------------


- (void)VideoPlayer:(VideoPlayerView *) videoplayer
    updatedPosition:(NSTimeInterval) time
{
    //NSLog(@"VideoPlayer.time: %f", time);
    VideoPlayerViewController *videoPlayerVC = (VideoPlayerViewController*) _mediaObject.mediaPlayer;
    self.videoProgressBar.progress = (float) time/videoPlayerVC.duration;
    
       NSDate* d = [NSDate dateWithTimeIntervalSince1970:time];
    //Then specify output format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:@"mm:ss.SSS"];
    
    NSString* timeStr = [dateFormatter stringFromDate:d];
    
    
    [self.playbackProgressLabel setText:timeStr];
    
    
}

//------------------------------------------------------------------------------


- (void)VideoPlayer:(VideoPlayerView *)videoplayer
reachedEndOfVideoFile:(AVPlayerItem *) videoAsset
{
    MWLogInfo(@"VideoPlayer reached end of media :%@", videoAsset.description);
}

//------------------------------------------------------------------------------

- (void) VideoPlayer:(VideoPlayerView *)videoplayer
   DurationAvailable:(NSTimeInterval) duration
{
    MWLogInfo(@"VideoPlayer.duration: %f", duration);
    
    
}

//------------------------------------------------------------------------------

- (void) VideoPlayer:(VideoPlayerView *)videoplayer
  TrackInfoAvailable:(NSArray<AVPlayerItemTrack *>*) tracks
{
    MWLogInfo(@"VideoPlayer item tracks: %@", tracks);
}

//------------------------------------------------------------------------------

- (void) VideoPlayer:(VideoPlayerView *)videoplayer
    LoadedTimeRanges:(NSArray*) ranges
{
    //NSLog(@"VideoPlayer buffering status: %@", ranges);
    
    
}


//------------------------------------------------------------------------------


@end
