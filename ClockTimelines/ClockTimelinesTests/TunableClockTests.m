//
//  TunableClockTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 12/05/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//
//
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "MonotonicTime.h"
#import "SystemClock.h"
#import "TunableClock.h"
#import "MockDependent.h"
#import "CorrelatedClock.h"


#define NUM_RUNS 100

@interface TunableClockTests : XCTestCase

@end


@implementation TunableClockTests
{
    SystemClock *sysCLK;
    NSMutableArray* changeList;
    MockDependent *md1;
}


- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testTunableClockInit
{
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];
    
    XCTAssertEqual(tuneCLK.tickRate, _kOneThousandMillion, @"tick rate initialised.");
    XCTAssertEqual(tuneCLK.speed, 1.0, @"speed initialised.");
    XCTAssertTrue(tuneCLK.startTicks > 0, @"startTicks initialised.");
    XCTAssertTrue(tuneCLK.lastTicks > 0, @"lastTicks initialised.");
    sleep(1.0);
    XCTAssertTrue([tuneCLK ticks] > 0, @"ticks");
    XCTAssertTrue([tuneCLK time] > 0.0, @"time ");
}

-(void) testGetParent
{
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
    XCTAssertEqualObjects(tuneCLK.parent, sysCLK);
    
}


-(void) testTunableClockTicking
{
    
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    NSLog(@"sysCLK ticks: %lld, time %f", [sysCLK ticks], [sysCLK time]);
    
    
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];
    
    uint64_t tickcount= [tuneCLK ticks];
    
    NSLog(@"TuneCLK ticks: %lld, time %f parent ticks: %lld", tickcount, [tuneCLK time], [tuneCLK toParentTicks:tickcount]);
    
    [tuneCLK adjustTicks:1234567891];
    
    
    NSLog(@"TuneCLK ticks: %lld, time %f parent ticks: %lld", [tuneCLK ticks], [tuneCLK time], [tuneCLK toParentTicks:[tuneCLK ticks]]);
    
    
    
    
    
    
    
}

- (void) testTunableClockParent
{
    
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];
    for(int i=0; i<NUM_RUNS; i++){
        NSLog(@"Sys Clock time : %f Tunable Clock time: %f " , [sysCLK time], [tuneCLK time]);
        
        // test for millisecond accuracy between system clock and a tunable clock emulating a system clock
        XCTAssertEqualWithAccuracy([sysCLK time], [tuneCLK time], 0.001);
    }
    
    NSLog(@"Sys Clock time : %lld Tunable Clock time: %lld " , [sysCLK nanoSeconds], [tuneCLK nanoSeconds]);
    
    XCTAssertEqualWithAccuracy([sysCLK nanoSeconds], [tuneCLK nanoSeconds], 10000);
}




/**
 *  Test the tunable clock
 */
- (void)testTunableClockAccuracy {
    UInt64 sysCLKTicks;
    UInt64 tuneCLKTicks;
    int64_t diff;
    
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    //create a tunable clock with start ticks equal to system clock current ticks and same tick rate as the system clock.
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];
    sleep(2.0);
    
    for(int i=0; i<NUM_RUNS; i++){
        sysCLKTicks = [sysCLK ticks];
        tuneCLKTicks = [tuneCLK ticks];
        diff = tuneCLKTicks - sysCLKTicks;
        
       // NSLog(@"System Clock ticks: %llu Tunable Clock ticks: %llu diff: %lld" , sysCLKTicks, tuneCLKTicks, diff);
        XCTAssertLessThan(llabs(diff), 100000, @"diff less than 0.1 ms");
    }
}


/**
 *  Test compute to host time function with a hierarchy of clocks
 */
- (void) testComputeTime
{
    // create a clock to simulate a WallClock
    
    MonotonicTime *montime = [[MonotonicTime alloc] init];
    sysCLK = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:_kOneThousandMillion Ticks:[sysCLK ticks]];
    
    
    // get current time in ticks from our clock objects
    int64_t hostTimeNanos = [montime timeNanos];
    
    int64_t nowTuneCLKTicks = [tuneCLK ticks];
    int64_t nowSysCLKTicks = [tuneCLK toParentTicks:nowTuneCLKTicks];
    
    NSLog(@"hosttime nanos: %lld", hostTimeNanos);
    
    Float64 nowSysCLKNanos = [sysCLK ticksToNanoSeconds:nowSysCLKTicks];
    
    Float64 nowSysCLKHostTimeNanos = [sysCLK computeTimeNanos:nowSysCLKTicks];
    
    NSLog(@"sysclock time nanos: %f hostTimeNanos: %f", nowSysCLKNanos, nowSysCLKHostTimeNanos);
    
    
    
    Float64 nowTuneCLKNanos = [tuneCLK ticksToNanoSeconds:nowTuneCLKTicks];
    Float64 nowTuneCLKHostTimeNanos = [tuneCLK computeTimeNanos:nowTuneCLKTicks];
    
    NSLog(@"tuneclock time nanos: %f hostTimeNanos: %f", nowTuneCLKNanos, nowTuneCLKHostTimeNanos);
    
    XCTAssertEqualWithAccuracy(hostTimeNanos,nowSysCLKHostTimeNanos, 1000);
    XCTAssertEqualWithAccuracy(nowSysCLKHostTimeNanos,nowSysCLKHostTimeNanos, 1);
   
    
    /// adjust tunable clock offset (simulating a wallclock adjustment) and test again
    
    [tuneCLK adjustTimeNanos:-49298740533460];
    hostTimeNanos = [montime timeNanos];
    nowTuneCLKTicks = [tuneCLK ticks];
    nowSysCLKTicks = [tuneCLK toParentTicks:nowTuneCLKTicks];
    
    NSLog(@"hosttime nanos: %lld", hostTimeNanos);
    
    nowSysCLKNanos = [sysCLK ticksToNanoSeconds:nowSysCLKTicks];
    
    nowSysCLKHostTimeNanos = [sysCLK computeTimeNanos:nowSysCLKTicks];
    
    NSLog(@"sysclock time nanos: %f hostTimeNanos: %f", nowSysCLKNanos, nowSysCLKHostTimeNanos);
    
    
    nowTuneCLKNanos = [tuneCLK ticksToNanoSeconds:nowTuneCLKTicks];
    nowTuneCLKHostTimeNanos = [tuneCLK computeTimeNanos:nowTuneCLKTicks];
    
    NSLog(@"tuneclock time nanos: %f hostTimeNanos: %f  after offset adjustment", nowTuneCLKNanos, nowTuneCLKHostTimeNanos);
    
   
    XCTAssertEqualWithAccuracy(hostTimeNanos,nowSysCLKHostTimeNanos, 1000);
    XCTAssertEqualWithAccuracy(nowSysCLKHostTimeNanos,nowSysCLKHostTimeNanos, 1);
    
    
   
    // create a clock to simulate a TV PTS timeline, 90000 ticks per second
    Correlation corel = [CorrelationFactory create:34998318431864 Correlation:3547799];
    CorrelatedClock *corelCLK = [[CorrelatedClock alloc] initWithParentClock:tuneCLK TickRate:90000 Correlation:&corel];
    
    int64_t nowcorelCLKTicks = [corelCLK ticks];
    nowTuneCLKTicks = [corelCLK toParentTicks:nowcorelCLKTicks];
    nowSysCLKTicks = [tuneCLK toParentTicks:nowTuneCLKTicks];
    Float64 nowcorelCLKNanos = [corelCLK ticksToNanoSeconds:nowcorelCLKTicks];
    Float64 nowcorelCLKHostTimeNanos = [corelCLK computeTimeNanos:nowcorelCLKTicks];

    nowSysCLKNanos = [sysCLK ticksToNanoSeconds:nowSysCLKTicks];
    
    nowSysCLKHostTimeNanos = [sysCLK computeTimeNanos:nowSysCLKTicks];
    
    NSLog(@"sysclock time nanos: %f hostTimeNanos: %f", nowSysCLKNanos, nowSysCLKHostTimeNanos);
    
    
    nowTuneCLKNanos = [tuneCLK ticksToNanoSeconds:nowTuneCLKTicks];
    nowTuneCLKHostTimeNanos = [tuneCLK computeTimeNanos:nowTuneCLKTicks];
    
    NSLog(@"tune clock time nanos: %f hostTimeNanos: %f ", nowTuneCLKNanos, nowTuneCLKHostTimeNanos);
    NSLog(@"corel clock time nanos: %f hostTimeNanos: %f ", nowcorelCLKNanos, nowcorelCLKHostTimeNanos);
    
    corelCLK = nil;
    
    
    nowTuneCLKNanos = [tuneCLK ticksToNanoSeconds:nowTuneCLKTicks];
    
    // use MTTestSemaphore to 

    
}



@end
