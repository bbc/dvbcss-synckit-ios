//
//  ViewController.m
//  WallClockClientDemoApp
//
//  Created by Rajiv Ramdhany on 17/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import "ViewController.h"
#import <WallClockClient/WallClockClient.h>
#import <ClockTimelines/ClockTimelines.h>
#import <TimelineSync/TimelineSync.h>
#import "PropertyChange.h"

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------


//NSString *serverAddress     = @"192.168.1.112";
//NSString *contentId         = @"dvb://233A.4084.0001";
//NSString *timelineSelector  = @"urn:dvb:css:timeline:pts";
//NSString *tsEndpointURL     = @"ws://192.168.1.112:7682";

NSString *serverAddress     = @"192.168.0.13";
NSString *contentId         = @"dvb://233A.4084.0001";
NSString *timelineSelector  = @"urn:dvb:css:timeline:pts";
NSString *tsEndpointURL     = @"ws://192.168.0.13:7682";

static void *WallClockContext = &WallClockContext;
static void *TVTimelineContext = &TVTimelineContext;

/**
 *  The start position of the programme on the TV timeline.
 *  this is specific to the TV stream which we are synchronising to.
 */
Float64 testProgrammeStartTicks = 900000;



//------------------------------------------------------------------------------
#pragma mark - ViewController (Interface Extension)
//------------------------------------------------------------------------------

@interface ViewController () <TimelineSynchroniserDelegate>

/**
 *  Sync status
 */
@property (nonatomic, readwrite) BOOL running;



@end



//------------------------------------------------------------------------------
#pragma mark - ViewController implementation
//------------------------------------------------------------------------------

@implementation ViewController
{
    SystemClock             *sysCLK;            // a system clock based on this device monotonic time
    TunableClock            *wallclock;         // a WallClock whose time will be synchronised using the WC protocol
    id<IWCAlgo>             algorithm;          // an algorithm for processing candidate measurements
    id<IFilter>             filter;             // a filter to reject unsuitable candidate measurements
    NSMutableArray          *filterList;        // a filter list
    WallClockSynchroniser   *wallclock_syncer;  // a wallclock synchronisation
    dispatch_source_t       UIUpdateTimer;
    CorrelatedClock         *tvPTSTimeline;     // a PTS timeline, selector = "urn:dvb:css:timeline:pts", tickrate =90000
    TimelineSynchroniser    *tvPTSTimelineSyncer;
    
}

//------------------------------------------------------------------------------
#pragma mark - ViewController, UI handler methods
//------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startWallClockSync];
    [self.startStopButton setTitle:@"Stop Sync" forState:UIControlStateNormal];
    
}

//------------------------------------------------------------------------------


- (void)dealloc
{
    [tvPTSTimeline removeObserver:self Context:TVTimelineContext];
}




//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - actions
//------------------------------------------------------------------------------

- (void) UIUpdateTask
{
    [self.wcOffsetTextField setText:[NSString stringWithFormat:@"%10f ms", (float)[wallclock_syncer getCandidateOffset]/1000000]];
    
    [self.dispersionTextField setText:[NSString stringWithFormat:@"%10f ms",(float)[wallclock_syncer getCurrentDispersion]/1000000]];
    
    [self.usefulTimeTextField setText:[NSString stringWithFormat:@"%10f ms", (float)[wallclock_syncer getTimeBetweenUsefulCandidates]/1000000]];
    
    [self.usefulCandPercentTextField setText:[NSString stringWithFormat:@"%4f %%", [wallclock_syncer getUsefulCandidatesPercent]]];
    
    
    
    
    
    // read TV Timeline
    Float64 currentTVTimeSecs;
//    if (tvPTSTimeline.available)
//    {
//        int64_t timelineNowTicks = [tvPTSTimeline ticks];
//    //    NSLog(@"ViewController.UIUpdateTask: current TVTime ticks %lld", timelineNowTicks);
//    //    self.programTimeLabel.text = [NSString stringWithFormat:@"%lld", timelineNowTicks];
//        
//        currentTVTimeSecs = [tvPTSTimeline time];
//        NSLog(@"ViewController.UIUpdateTask: current TVTime %f %f", currentTVTimeSecs, (timelineNowTicks*1.0)/90000);
//    }
    
    if (tvPTSTimeline.available)
    {
        
        currentTVTimeSecs = ([tvPTSTimeline time]);
        //NSLog(@"ViewController.UIUpdateTask: current TVTime %f", currentTVTimeSecs);
        
        
    }else{
        currentTVTimeSecs = 0;
    }
    
    Float64 testProgrammeStartTimeSecs = testProgrammeStartTicks/90000;
    //NSLog(@"ViewController.UIUpdateTask: testProgrammeStartTimeSecs %f", testProgrammeStartTimeSecs);
    
    Float64 timeSinceProgStartSecs = currentTVTimeSecs - testProgrammeStartTimeSecs;
    
    // NSLog(@"ViewController.UIUpdateTask: timeSinceProgStartSecs %f", timeSinceProgStartSecs);
    
//    NSDate* d = [NSDate dateWithTimeIntervalSince1970:timeSinceProgStartSecs];
//    //Then specify output format
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    [dateFormatter setDateFormat:@"mm:ss.SSS"];
//    
//    self.programTimeLabel.text = [dateFormatter stringFromDate:d];
    
    self.programTimeLabel.text = [NSString stringWithFormat:@"%lf", timeSinceProgStartSecs];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//------------------------------------------------------------------------------

dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        
    }
    return timer;
}

//------------------------------------------------------------------------------

- (IBAction)startStopSync:(id)sender {
    
    
    
    if (!self.running)
    {
        [self startTimelineSync];
        
        
    }else{
        
        [self stopTimelineSync];
       
    }
    
   

    
}

//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - KVO for WallClock and TVTimeline
//------------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if (context == WallClockContext) {
        if ([keyPath isEqualToString:kAvailableKey])
        {
            NSNumber *newAvailability = [change objectForKey:@"new"];
            
            // only start timeline sync when wallclock is in sync
            if (([newAvailability boolValue] == YES) && (tvPTSTimelineSyncer==nil)){
                [self startTimelineSync];
            }
            
        }
        
        
        
    }
    else if (context == TVTimelineContext) {
        NSString* msg;
        
//        PropertyChange *pchg =  [[PropertyChange alloc] initWithName:keyPath oldValue:[change valueForKey:@"old"] NewValue:[change valueForKey:@"new"]];
        
        
        
        //msg= [NSString stringWithFormat:@" TV Timeline changed: %@", pchg.description ];
        
        //NSLog(@"ViewController: TV Timeline %lu changed %@",(unsigned long)[object hash] ,[pchg description]);
        
        if ([keyPath isEqualToString:kTickRateKey]) {
            
            
        }else if ([keyPath isEqualToString:kSpeedKey]) {
            
            NSLog(@"ViewController: tvPTSTimeline speed changed.");
            
        }else if([keyPath isEqualToString:kCorrelationKey]) {
            NSLog(@"ViewController: tvPTSTimeline correlation changed.");
            
            
            Correlation newCorel;
            
            //id oldobj = [change objectForKey:@"old"];
            id newobj = [change objectForKey:@"new"];
            
            
            if ([newobj isKindOfClass:[NSValue class]])
            {
                [newobj getValue:&newCorel];
                msg = [NSString stringWithFormat:@"contentTime: %lld wallClockTime: %lld", newCorel.tickValue, newCorel.parentTickValue];
            }
            
            
        }else if ([keyPath isEqualToString:kAvailableKey]) {
            
            
        }
        
        self.infoLabel.text = msg;
    }
    
    
   
    
    
}

//------------------------------------------------------------------------------
#pragma mark - TimelineSynchroniserDelegate methods
//------------------------------------------------------------------------------

- (void) ts:(TimelineSynchroniser*) ts DidChangeState:(TSState) state
{
    // NSLog(@"TimelineSynchroniser state : %u", state);
}



//------------------------------------------------------------------------------
#pragma mark - private methods
//------------------------------------------------------------------------------

/**
 *  Start WallClock Synchronisation
 */
- (void)startWallClockSync {
    
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    // --- start WallClock Sync ----
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    wallclock = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];
    
    algorithm = [[LowestDispersionAlgorithm alloc] initWithWallClock:wallclock];
    filter = [[RTTThresholdFilter alloc] initWithThreshold:100];
    filterList = [NSMutableArray arrayWithObject:filter];
    
    wallclock_syncer = [[WallClockSynchroniser alloc] initWithWCServer:serverAddress
                                                                  Port:6677 WallClock:wallclock
                                                             Algorithm:algorithm
                                                            FilterList:filterList];
    [wallclock addObserver:self forKeyPath:kAvailableKey options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:WallClockContext];
    
    [wallclock_syncer start];
}

//------------------------------------------------------------------------------

/**
 *  Start timeline synchronisation
 */
- (void)startTimelineSync {
    // -- start Timeline Sync ----
    // create a timeline object to synchronise
    Correlation corel = [CorrelationFactory create:0 Correlation:0];
    tvPTSTimeline = [[CorrelatedClock alloc] initWithParentClock:wallclock
                                                        TickRate:90000
                                                     Correlation:&corel]; // timeline created but unavailable
    
    tvPTSTimelineSyncer = [TimelineSynchroniser TimelineSynchroniserWithTimeline:tvPTSTimeline
                                                                TimelineSelector:timelineSelector
                                                                         Content:contentId
                                                                             URL:tsEndpointURL];
    assert(tvPTSTimelineSyncer!=nil);
    
    tvPTSTimelineSyncer.delegate = self;
    
    [tvPTSTimeline addObserver:self context:TVTimelineContext];
    
    
    [tvPTSTimelineSyncer start];
    [self.startStopButton setTitle:@"Stop Sync" forState:UIControlStateNormal];
    self.running = true;
    
    if (!UIUpdateTimer) {
        UIUpdateTimer = CreateDispatchTimer(10*NSEC_PER_MSEC,
                                            1* NSEC_PER_MSEC,
                                            dispatch_get_main_queue(),
                                            ^{ [self UIUpdateTask]; });
    }
    dispatch_resume(UIUpdateTimer);
    
}

//------------------------------------------------------------------------------

- (void)stopTimelineSync {
    
    
     dispatch_source_cancel(UIUpdateTimer);
    
    [tvPTSTimelineSyncer stop];
    [tvPTSTimeline removeObserver:self Context:TVTimelineContext ];
    tvPTSTimelineSyncer= nil;
    tvPTSTimeline= nil;
    UIUpdateTimer = nil;

    [self.startStopButton setTitle:@"Start Sync" forState:UIControlStateNormal];
    
    self.running = false;
}

//------------------------------------------------------------------------------

@end
