//
//  ViewController.m
//  TestVideoPlayer
//
//  Created by Rajiv Ramdhany on 08/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//

#import "ViewController.h"
#import <VideoPlayer/VideoPlayerError.h>
#import <VideoPlayer/VideoPlayerView.h>
#import <VideoPlayer/VideoPlayerViewController.h>

@interface ViewController () <VideoPlayerDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIView *VideoView;

//------------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIProgressView *progressBarView;

//------------------------------------------------------------------------------
@property (retain, nonatomic) VideoPlayerViewController *videoPlayerController;

//------------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIView *buttonBarView;

//------------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIButton *PauseButton;

@property (nonatomic) NSArray* bufferedRange;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Video1 button handler
 *
 *  @param sender button
 */
- (IBAction)Video1ButtonTapped:(id)sender;

//------------------------------------------------------------------------------

/**
 *  Video2 button handler
 *
 *  @param sender button
 */
- (IBAction)Video2ButtonTapped:(id)sender;

//------------------------------------------------------------------------------

- (IBAction)PauseButtonTapped:(id)sender;

//------------------------------------------------------------------------------

- (IBAction)RunTestButtonTapped:(id)sender;

//------------------------------------------------------------------------------

@end




//------------------------------------------------------------------------------
#pragma mark - Implementation
//------------------------------------------------------------------------------
@implementation ViewController
{
    NSURL *url;
}


//------------------------------------------------------------------------------
#pragma mark - UIViewController Methods
//------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view bringSubviewToFront:self.buttonBarView];
    [self.view bringSubviewToFront:self.progressBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (IBAction)Video1ButtonTapped:(id)sender {
    
    
    if (self.videoPlayerController)
    {
        
        [self.videoPlayerController stopAndRemoveFromParentView];
        self.videoPlayerController =  nil;
        
    }
    
    self.videoPlayerController = [[VideoPlayerViewController alloc] initWithParentView:self.VideoView Delegate:self];
    url = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    
    self.videoPlayerController.videoURL = url;
    
    self.videoPlayerController.shouldLoop = YES;
    
    [self.progressBarView setProgress:0.0];
    
    [self.view bringSubviewToFront:self.buttonBarView];
    [self.view bringSubviewToFront:self.progressBarView];
    
    
    
    
}


- (IBAction)Video2ButtonTapped:(id)sender {
    
    if (self.videoPlayerController)
    {
        
        [self.videoPlayerController stopAndRemoveFromParentView];
        self.videoPlayerController =  nil;
        
    }
    
   

    self.videoPlayerController = [[VideoPlayerViewController alloc] initWithParentView:self.VideoView Delegate:self];
    //url = [[NSBundle mainBundle] URLForResource:@"wc_final" withExtension:@"mp4"];
    
     url = [NSURL URLWithString:@"http://localhost/~rajivr/video/wcfinallg/wcfinal_index.m3u8"];
//     //@"http://v.ch.bbc.co.uk/hls_live/slides-1280x720.m3u8"
//   
    self.videoPlayerController.videoURL = url;
    
    [self.progressBarView setProgress:0.0];

}

- (IBAction)PauseButtonTapped:(id)sender {
    
    NSLog(@"ViewController.PauseButtonTapped() - video player state: %lu", self.videoPlayerController.state);
    
    if (self.videoPlayerController.state == VideoPlayerStatePlaying)
    {
        [self.videoPlayerController pause];
        [self.PauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }else if (self.videoPlayerController.state == VideoPlayerStatePaused)
    {
        [self.videoPlayerController play];
        [self.PauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)RunTestButtonTapped:(id)sender {
    
    // test setRate
    //[self testSetRate];
    
    // test seek within video file
    //[self testSeekToValidTimeWithinFile];
    
    // test seek beyond video eof
    // [self testSeekToinvalidTimeWithinFile];
    
    // test seek within a loaded segment
    [self testSeekToValidTimeWithinCurrentHLSSegment];
    
}


//------------------------------------------------------------------------------
#pragma mark - VideoPlayerDelegate methods
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------


-(void) VideoPlayer:(VideoPlayerView *) videoplayer
              State:(VideoPlayerState) state{
    
    NSLog(@"VideoPlayer.state: %lu", state);
    
    if (state == VideoPlayerStateReadyToPlay) [self.videoPlayerController play];
    
    [self.view bringSubviewToFront:self.buttonBarView];
    
    
}

//------------------------------------------------------------------------------


- (void)VideoPlayer:(VideoPlayerView *) videoplayer
    updatedPosition:(NSTimeInterval) time
{
    //NSLog(@"VideoPlayer.time: %f", time);
    
    self.progressBarView.progress = time/self.videoPlayerController.duration;
}

//------------------------------------------------------------------------------


- (void)VideoPlayer:(VideoPlayerView *)videoplayer
reachedEndOfVideoFile:(AVPlayerItem *) videoAsset
{
    NSLog(@"VideoPlayer reached end of media :%@", videoAsset.description);
}

//------------------------------------------------------------------------------

- (void) VideoPlayer:(VideoPlayerView *)videoplayer
   DurationAvailable:(NSTimeInterval) duration
{
    NSLog(@"VideoPlayer.duration: %f", duration);
}

//------------------------------------------------------------------------------

- (void) VideoPlayer:(VideoPlayerView *)videoplayer
  TrackInfoAvailable:(NSArray<AVPlayerItemTrack *>*) tracks
{
     NSLog(@"VideoPlayer item tracks: %@", tracks);
}

//------------------------------------------------------------------------------

- (void) VideoPlayer:(VideoPlayerView *)videoplayer
    LoadedTimeRanges:(NSArray*) ranges
{
    NSLog(@"VideoPlayer buffering status: %@", ranges);
    self.bufferedRange = ranges;

}


//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - Tests to Run (called by RunTestButtonTapped method)
//------------------------------------------------------------------------------
/**
 *   simple way of running some tests.
 */


- (void) testSetRate
{
    if (self.videoPlayerController)
    {
        [self.videoPlayerController setRate:2.0];
        
        
        if (self.videoPlayerController.videoPlayer.player.rate !=2.0) {
            NSLog(@"testSetRate failed.");
        }
        
    }
    
    
    
}


- (void) testSeekToValidTimeWithinFile
{
    if (self.videoPlayerController)
    {
//        NSTimeInterval duration = self.videoPlayerController.duration;
        
        
        [self.videoPlayerController seekToTime:20.0];
        
        
        if (self.videoPlayerController.currentTime < 20.0) {
            NSLog(@"testSeekToValidTime failed.");
        }
        
    }
    
    
    
}


- (void) testSeekToinvalidTimeWithinFile
{
    if (self.videoPlayerController)
    {
        NSTimeInterval duration = self.videoPlayerController.duration;
        
        // seek to beyond end of file
        [self.videoPlayerController seekToTime:duration+10];
        
        
       
        
    }
    
    
    
}

- (void) testSeekToValidTimeWithinCurrentHLSSegment
{
//    if (self.videoPlayerController)
//    {
//       NSArray<NSValue*>* range = [self.bufferedRange copy];
//        
//        CMTimeRan * val = range.firstObject;
//        CMTimeRange timerange;
//        [val getValue:&timerange];
//        
//        CMTime *startBuffered = &timerange.start;
//        CMTime *durationBUffered = &timerange.duration;
//        
//        
//        
//        NSTimeInterval duration = self.videoPlayerController.duration;
//        
//        
        [self.videoPlayerController seekToTime:10.6];
        
        
        if (self.videoPlayerController.currentTime < 10.6) {
            NSLog(@"testSeekToValidTime failed.");
        }
//
//    }
//    
    
    
}

- (void) testSeekToValidTimeWithinHLSBufferedData
{

//    NSArray* range = self.bufferedRange;
//    
//    // NSTimeInterval startTimeInBuffer = ((CMTime) self.bufferedRange[0]);
//    
//    
//    
    
}


- (void) testSeekToValidTimeOutsideHLSBufferedData
{
    
}




@end
