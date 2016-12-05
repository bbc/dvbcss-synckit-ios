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

@interface ViewController ()

@property (nonatomic, readwrite) BOOL running;

@end

//@"192.168.1.102"
const NSString *serverAddress = @"192.168.0.13";


@implementation ViewController
{
    SystemClock             *sysCLK;            // a system clock based on this device monotonic time
    TunableClock            *wallclock;         // a WallClock whose time will be synchronised using the WC protocol
    id<IWCAlgo>             algorithm;          // an algorithm for processing candidate measurements
    id<IFilter>             filter;             // a filter to reject unsuitable candidate measurements
    NSMutableArray          *filterList;        // a filter list
    WallClockSynchroniser   *wallclock_syncer;  // a component that drives our time synchronisation
    dispatch_source_t       UIUpdateTimer;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    wallclock = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:0];
    
    algorithm = [[LowestDispersionAlgorithm alloc] initWithWallClock:wallclock];
    filter = [[RTTThresholdFilter alloc] initWithThreshold:1000];
    filterList = [NSMutableArray arrayWithObject:filter];
    
    wallclock_syncer = [[WallClockSynchroniser alloc] initWithWCServer:serverAddress
                                                                  Port:6677 WallClock:wallclock
                                                             Algorithm:algorithm
                                                            FilterList:filterList];
    self.running = false;
    
}


- (void) UIUpdateTask
{
    [self.wcOffsetTextField setText:[NSString stringWithFormat:@"%10f ms", (float)[wallclock_syncer getCandidateOffset]/1000000]];
    
    [self.dispersionTextField setText:[NSString stringWithFormat:@"%10f ms",(float)[wallclock_syncer getCurrentDispersion]/1000000]];
    
    [self.usefulTimeTextField setText:[NSString stringWithFormat:@"%10f ms", (float)[wallclock_syncer getTimeBetweenUsefulCandidates]/1000000]];
    
    [self.usefulCandPercentTextField setText:[NSString stringWithFormat:@"%4f %%", [wallclock_syncer getUsefulCandidatesPercent]]];
    
    int64_t wallclocktime_in_ticks = [wallclock ticks];
    Float64 wallclocktime_in_secs = ([wallclock ticksToNanoSeconds:wallclocktime_in_ticks]*1.0)/wallclock.tickRate;
    
    NSLog(@"ViewController.UIUpdateTask: WallClock ticks: %lld second: %lf nowsecs:%lf", wallclocktime_in_ticks, wallclocktime_in_secs, [wallclock computeTime:wallclocktime_in_ticks]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)StartWallClock:(id)sender {
    
    
    
    if (!self.running)
    {
        
        [wallclock_syncer start];
        
        if (!UIUpdateTimer) {
            UIUpdateTimer = CreateDispatchTimer(250*NSEC_PER_MSEC,
                                                100* NSEC_PER_MSEC,
                                                dispatch_get_main_queue(),
                                                ^{ [self UIUpdateTask]; });
        }
        dispatch_resume(UIUpdateTimer);
        
        [self.startStopButton setTitle:@"Stop WallClock Sync" forState:UIControlStateNormal];
        
    }else{
        dispatch_source_cancel(UIUpdateTimer);
        UIUpdateTimer = nil;
        
        [wallclock_syncer stop];
        [self.startStopButton setTitle:@"Start WallClock Sync" forState:UIControlStateNormal];
    }
    
    self.running = !self.running;
    
    
    
}

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


@end
