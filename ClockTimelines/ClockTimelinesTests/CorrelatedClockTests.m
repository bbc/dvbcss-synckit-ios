//
//  CorrelatedClockTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 20/05/2015.
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


#import "MonotonicTime.h"
#import "CorrelatedClock.h"
#import "SystemClock.h"
#import "MockObserver.h"
#import "TunableClock.h"

@interface CorrelatedClockTests : XCTestCase

@end

@implementation CorrelatedClockTests
{
    NSMutableArray* changeList;
    CorrelatedClock *corelCLK, *corelCLK_a, *corelCLK_b;
    TunableClock *tuneCLK;
}

- (void)setUp {
    [super setUp];
    
    changeList =  [[NSMutableArray alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetParent {
    
    SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel = [CorrelationFactory create:0 Correlation:500];
    
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysCLK TickRate:1000 Correlation:&corel];
    
    XCTAssertEqualObjects(corelCLK.parent,sysCLK);
    
    
}


- (void) testRebase
{
    
    SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000];
    
    Correlation corel = [CorrelationFactory create:50 Correlation:300];
    
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysCLK TickRate:1000 Correlation:&corel];
    
    [corelCLK rebaseCorrelationAtTicks:400];
    
    XCTAssertEqual(corelCLK.correlation.parentTickValue, 150);
    XCTAssertEqual(corelCLK.correlation.tickValue, 400);
    
}

-(void) testChangeSpeedNotification
{
    // our clock hierarchy
    SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel = [CorrelationFactory create:0 Correlation:300];
    
    corelCLK_a = [[CorrelatedClock alloc] initWithParentClock:sysCLK TickRate:1000 Correlation:&corel];
    
    Correlation corel2 = [CorrelationFactory create:0 Correlation:0];
    corelCLK_b = [[CorrelatedClock alloc] initWithParentClock:corelCLK_a TickRate:50 Correlation:&corel2];
    
    //observers
    MockObserver *sysclk_obs = [[MockObserver alloc] init];
    MockObserver *corelCLK_a_obs = [[MockObserver alloc] init];
    MockObserver *corelCLK_b_obs = [[MockObserver alloc] init];
    
    
    [sysCLK addObserver:sysclk_obs context:nil];
    [corelCLK_a addObserver: corelCLK_a_obs context:nil];
    [corelCLK_b addObserver:corelCLK_b_obs context:nil];
    
    // change speed value of a clock
    corelCLK_a.speed =0.5;
    
    // check if dependents have been notified
    PropertyChange* pchg = [[PropertyChange alloc] initWithName:@"speed" oldValue:[NSNumber numberWithFloat:1.0] NewValue:[NSNumber numberWithFloat:corelCLK_a.speed]];
    
    [changeList addObject:pchg];
    
    XCTAssertTrue([corelCLK_a_obs checkNotified:changeList]);
    
    XCTAssertTrue([sysclk_obs checkNotNotified:changeList]);
    
    
    [changeList removeAllObjects];
    
    // when corelCLK_b is notified about corelCLK_a's speed change,
    // it in turn notifies its observers
    // by re-setting its own speed property to the same value as before.
    
    // we detect change with old and new value being equal. This change means
    // that something changed in the parent clock.
    PropertyChange* pchg_2 = [[PropertyChange alloc] initWithName:@"speed" oldValue:[NSNumber numberWithFloat:1.0] NewValue:[NSNumber numberWithFloat:1.0]];
    [changeList addObject: pchg_2];
    XCTAssertTrue([corelCLK_b_obs checkNotified:changeList]);
    
    
}





@end
