  //
//  CorrelatedClockTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 06/05/2015.
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
#import "CorrelatedClock.h"
#import "SystemClock.h"
#import "MockDependent.h"
#import "TunableClock.h"
#import "MockObserver.h"


static void *correlatedClockContext = &correlatedClockContext;

@interface CorrelatedClockSwizzlerTests : XCTestCase

@end

@implementation CorrelatedClockSwizzlerTests
{
    NSMutableArray* changeList;
    MockDependent *md1;
    TunableClock *tuneCLK;
    CorrelatedClock *corelCLK, *corelCLK_a, *corelCLK_b;
}
double timenow;
static IMP __originalTimeMethod_Imp;

- (void)setUp {
    [super setUp];
    
    changeList =  [[NSMutableArray alloc] init];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // swizzle time method in MonotonicTime class
        Class montime_cls = [MonotonicTime class];
        
        SEL originalTimeSelector = @selector(time);
        
        //        Method originalTimeMethod = class_getClassMethod(montime_cls, originalTimeSelector);
        IMP mockTimeMethodImp = (IMP) mockTime;
        char* method_types = "d@:";
        
        __originalTimeMethod_Imp = class_replaceMethod(montime_cls, originalTimeSelector, mockTimeMethodImp, method_types);
    });

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCorrelatedClockInitialisation {
    
    SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel = [CorrelationFactory create:0 Correlation:500];
    
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysCLK TickRate:1000 Correlation:&corel];
    
    
    XCTAssertEqual(corelCLK.correlation.parentTickValue, 0);
    XCTAssertEqual(corelCLK.correlation.tickValue, 500);
    XCTAssertEqual(corelCLK.tickRate, 1000);
}


- (void) testCorrelatedClockTicking
{
    
    timenow= 5020.8;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel = [CorrelationFactory create:0 Correlation:500];
    
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];
    
    XCTAssertEqualWithAccuracy([corelCLK ticks], (5020.8 * 1000) + 500, 0.0001, @"");
    NSLog(@" CorrelatedClock ticks: %llu expected value: %f", [corelCLK ticks], (5020.8 * 1000) + 500);
    
    timenow += 22.7;
    XCTAssertEqualWithAccuracy([corelCLK ticks], ((5020.8 + 22.7) * 1000) + 500, 0.0001, @"");
    NSLog(@" CorrelatedClock ticks: %llu expected value: %f", [corelCLK ticks], ((5020.8 + 22.7) * 1000) + 500);
}

-(void) testChangeCorrelation
{
    timenow= 5020.8;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:1000000];
    
    NSLog(@"sysclock time: %f", [sysclock time]);
    
    Correlation corel = [CorrelationFactory create:0 Correlation:500];
    
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];
    
    XCTAssertEqualWithAccuracy([corelCLK ticks], (5020.8*1000) + 500, 0.01,@"PASS, correct tick value for this correlated timeline");
    NSLog(@"timenow=50320.8, Correlation=(0,500), tickvalue = %llu", (UInt64) (5020.8*1000) + 500);
    NSLog(@"corelCLK time: %f", [corelCLK time]);
    
    
    // update correlation
    Correlation corel_new = [CorrelationFactory create:50000 Correlation:520];
    corelCLK.correlation =  corel_new;
    
    XCTAssertEqualWithAccuracy([corelCLK ticks], ((5020.8*1000000) - 50000)/1000 + 520, 0.01,@"PASS, correct tick value for this correlated timeline");
    NSLog(@"timenow=5020.8, Correlation=(0,500), tickvalue = %llu", (UInt64) ((5020.8*1000000) - 50000)/1000 + 520);


    
}

- (void) testChangeCorrelationNotification
{
    
    // set the monotonic time
    timenow= 5030.8;
    
    // A system clock that uses our swizzled monotonic time and that drives our correlated clock object
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:1000000];
    
    // Correlation Clock with correlation
    Correlation corel = [CorrelationFactory create:0 Correlation:500];
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];
    
    // an observer
    md1 = [[MockDependent alloc] init];
    
    [corelCLK addObserver:md1 context:nil];

    // change correlation relationship
    for (int i=1; i<=10; i++) {
        Correlation corel_new = [CorrelationFactory create:100*i Correlation:5000*i];
        Correlation corel_old = corelCLK.correlation;
        
        // record clock tick rate change
        NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
        NSValue *correlation_old_val = [NSValue valueWithBytes: &corel_old objCType:@encode(Correlation)];
        NSValue *correlation_new_val = [NSValue valueWithBytes:&corel_new objCType:@encode(Correlation)];
        
        [change setObject:correlation_old_val forKey:@"old"];
        [change setObject:correlation_new_val forKey:@"new"];
        
        // record change in changelist
        [changeList addObject:change];
        
        // carry out actual change
        corelCLK.correlation = corel_new;
    }
    sleep(2.0);
    
    [self assertNotified];
    [corelCLK removeObserver:md1 Context:nil];
}



- (void) assertNotified{

    XCTAssertTrue([changeList count] == [md1.notifications count]);
    
    for (UInt32 i=0; i<[changeList count]; i++) {
        NSDictionary *changeDict = [changeList objectAtIndex:i];
        NSDictionary *notifDict = [md1.notifications objectAtIndex:i];
        
        // recorded change, old correlation
        NSValue *oldcorel_val_One = [changeDict valueForKey:@"old"];
        Correlation oldCorel1;
        [oldcorel_val_One getValue:&oldCorel1];

        
        // KVO notification, old correlation
        NSValue *oldcorel_val_Two = [notifDict valueForKey:@"old"];
        Correlation oldCorel2;
        [oldcorel_val_Two getValue:&oldCorel2];

        NSValue *newcorel_val_One = [changeDict valueForKey:@"new"];
        Correlation newCorel1;
        [newcorel_val_One getValue:&newCorel1];

        NSValue *newcorel_val_Two = [notifDict valueForKey:@"new"];
        Correlation newCorel2;
        [newcorel_val_Two getValue:&newCorel2];

      
        
        XCTAssertEqual(oldCorel1.parentTickValue, oldCorel2.parentTickValue);
        XCTAssertEqual(newCorel1.parentTickValue, newCorel2.parentTickValue);
        XCTAssertEqual(oldCorel1.tickValue, oldCorel2.tickValue);
        XCTAssertEqual(newCorel1.tickValue, newCorel2.tickValue);
        
        NSLog(@"recorded change,    \t old correlation:(%llu,%llu)", oldCorel1.parentTickValue, oldCorel1.tickValue);
        NSLog(@"KVO notification,   \t old correlation:(%llu,%llu)", oldCorel2.parentTickValue, oldCorel2.tickValue);
        NSLog(@"recorded change,    \t new correlation:(%llu,%llu)", newCorel1.parentTickValue, newCorel1.tickValue);
        NSLog(@"KVO notification,   \t new correlation:(%llu,%llu)", newCorel2.parentTickValue, newCorel2.tickValue);
    }
}


/**
 *  Check if a change in correlation propagate to dependents of this clock
 */
-(void) testChangeCorrelationNotification_
{
    // set a fixed monotonic time for test purposes
    timenow= 5030.8;
    
    // A system clock that uses our swizzled monotonic time
    SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000000];

    Correlation corel = [CorrelationFactory create:0 Correlation:300];
    corelCLK_a = [[CorrelatedClock alloc] initWithParentClock:sysCLK TickRate:1000 Correlation:&corel];
    
    Correlation corel_b = [CorrelationFactory create:0 Correlation:0];
    corelCLK_b = [[CorrelatedClock alloc] initWithParentClock:corelCLK_a TickRate:50 Correlation:&corel_b];
    
    NSLog(@"system time: %f, sysclk ticks:%llu", [sysCLK time], [sysCLK ticks]);
    NSLog(@"correlated clock A %lu time: %f ticks: %llu", (unsigned long)[corelCLK_a hash], [corelCLK_a time], [corelCLK_a ticks]);
    NSLog(@"correlated clock B %lu time: %f ticks: %llu", (unsigned long) [corelCLK_b hash] ,[corelCLK_b time], [corelCLK_b ticks]);
    
    //observers
    MockObserver *sysclk_obs = [[MockObserver alloc] init];
    MockObserver *corelCLK_a_obs = [[MockObserver alloc] init];
    MockObserver *corelCLK_b_obs = [[MockObserver alloc] init];
    
    
    [sysCLK addObserver:sysclk_obs context:nil];
    [corelCLK_a addObserver: corelCLK_a_obs context:nil];
    [corelCLK_b addObserver:corelCLK_b_obs context:nil];
    
    // change correlation
    Correlation corel_new = [CorrelationFactory create:50 Correlation:20];
    corelCLK_a.correlation =  corel_new;
    
    NSValue *correlation_old_val = [NSValue valueWithBytes: &corel objCType:@encode(Correlation)];
    NSValue *correlation_new_val = [NSValue valueWithBytes:&corel_new objCType:@encode(Correlation)];

    
    
    // check if dependents have been notified
    PropertyChange* pchg = [[PropertyChange alloc] initWithName:@"correlation"
                                                       oldValue:correlation_old_val
                                                       NewValue:correlation_new_val];
    
    [changeList addObject:pchg];
    
    XCTAssertTrue([corelCLK_a_obs checkNotified:changeList]);
    
    XCTAssertTrue([sysclk_obs checkNotNotified:changeList]);
    
    
    [changeList removeAllObjects];
    
    // when corelCLK_b is notified about corelCLK_a's correlation change,
    // it in turn notifies its observers
    // by re-setting its own correlation property to the same value as before.
    
    // we detect change with old and new value being equal. This change means
    // that something changed in the parent clock.
    Correlation corel_x = [CorrelationFactory create:0 Correlation:0];
    Correlation corel_y = [CorrelationFactory create:0 Correlation:0];
    PropertyChange *pchg_2 = [[PropertyChange alloc] initWithName:@"correlation"
                                                         oldValue:[NSValue valueWithBytes: &corel_x
                                                                                 objCType:@encode(Correlation)]
                                                         NewValue:[NSValue valueWithBytes:&corel_y
                                                                                 objCType:@encode(Correlation)]
                              ];
    [changeList addObject: pchg_2];
    XCTAssertTrue([corelCLK_b_obs checkNotified:changeList]);
}


-(void) testToParentTicks
{
    timenow = 1000.0;
    
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:2000000];
    
    NSLog(@"system time: %f, sysclk ticks:%llu", [sysclock time], [sysclock ticks]);
    
  
    Correlation corel = [CorrelationFactory create:50 Correlation:300];
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];
    
    
    NSLog(@"Correlated clock toParentTicks(400) = %lld", [corelCLK toParentTicks: 400]);
    
    
   XCTAssertEqualWithAccuracy([corelCLK toParentTicks: 400], 50 + ((400-300)*2000), 0.0001);
    
}


-(void) testfromParentTicks
{
    timenow = 1000.0;
    
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:2000000];
    
    NSLog(@"system time: %f, sysclk ticks:%llu", [sysclock time], [sysclock ticks]);

    // Correlation Clock with correlation (1000000 parent ticks, 5000000 ticks) i.e. (1s, 5s)
    Correlation corel = [CorrelationFactory create:50 Correlation:300];
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];
    
    
    NSLog(@"Correlated clock time: %f", [corelCLK time]);
    
    
    XCTAssertEqualWithAccuracy([corelCLK fromParentTicks:(50 + (400-300)*2000)], 400, 0.0001);

}

/**
 *  Test if frequency updated correctly in CorrelatedClock
 */
- (void) testChangeFrequency
{
    timenow = 5020.80f;
    
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:1000000];
    
    NSLog(@"system time: %f, sysclk ticks:%llu", [sysclock time], [sysclock ticks]);
    
    // Correlation Clock with correlation (1000000 parent ticks, 5000000 ticks) i.e. (1s, 5s)
    Correlation corel = [CorrelationFactory create:50 Correlation:300];
    corelCLK = [[CorrelatedClock alloc] initWithParentClock:sysclock TickRate:1000 Correlation:&corel];
    
    // --- test tick value ---
    NSLog(@"Correlated clock time: %f", [corelCLK time]);
    XCTAssertEqualWithAccuracy([corelCLK ticks], (5020.8 * 1000000 -50)/(1000000/1000) + 300, 1, @"Correlated clock ticks test passed.");
    NSLog(@" CorrelatedClock ticks: %llu expected value: %f", [corelCLK ticks], (5020.8 * 1000000 -50)/(1000000/1000) + 300);
    
    // --- test frequency change ---
    XCTAssertEqual(corelCLK.tickRate, 1000, @"tick rate test passed.");
    corelCLK.tickRate = 500;
    XCTAssertEqual(corelCLK.tickRate, 500, @"tick rate change test.");
    
    XCTAssertEqualWithAccuracy([corelCLK ticks], (5020.8 * 1000000 -50)/(1000000/500) + 300, 1, @"Correlated clock ticks test passed.");
    NSLog(@" CorrelatedClock ticks: %llu expected value: %f", [corelCLK ticks], (5020.8 * 1000000 -50)/(1000000/500) + 300);
}

/**
 *  Test if observers are correctly notified of frequency (tick rate) changes in CorrelatedClock
 */
-(void) testChangeFrequencyNotification
{
    timenow = 5020.80f;
    
    // our clock hierarchy
    SystemClock *sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel = [CorrelationFactory create:50 Correlation:300];
    
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
    
    // change frequency of clock corelCLK_a
    corelCLK_a.tickRate =500;
    
    // check if dependents have been notified
    PropertyChange* pchg = [[PropertyChange alloc] initWithName:@"tickRate" oldValue:[NSNumber numberWithUnsignedLong:1000] NewValue:[NSNumber numberWithUnsignedLong:500]];
    
    [changeList addObject:pchg];
    
    XCTAssertTrue([corelCLK_a_obs checkNotified:changeList]);
    
    XCTAssertTrue([sysclk_obs checkNotNotified:changeList]);
    
    
    [changeList removeAllObjects];
    
    // when corelCLK_b is notified about corelCLK_a's speed change,
    // it in turn notifies its observers
    // by re-setting its own speed property to the same value as before.
    
    // we detect change with old and new value being equal. This change means
    // that something changed in the parent clock.
    PropertyChange* pchg_2 = [[PropertyChange alloc] initWithName:@"tickRate" oldValue:[NSNumber numberWithUnsignedLong:50] NewValue:[NSNumber numberWithUnsignedLong:50]];
    [changeList addObject: pchg_2];
    XCTAssertTrue([corelCLK_b_obs checkNotified:changeList]);

    
    
    
    
}





// ------------------- utility methods ---------------
Float64 mockTime(id self, SEL _cmd)
{
    assert([NSStringFromSelector(_cmd) isEqualToString:@"time"]);
    return timenow;
}



- (void)dealloc
{
    Class montime_cls = [MonotonicTime class];
    
    SEL originalTimeSelector = @selector(time);
    char* method_types = "d@:";
    class_replaceMethod(montime_cls, originalTimeSelector, __originalTimeMethod_Imp, method_types);
}
@end
