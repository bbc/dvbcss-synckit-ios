//
//  SystemClockTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 23/04/2015.
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


@interface SystemClockTests : XCTestCase

@end

@implementation SystemClockTests


double timenow;
static IMP __originalTimeMethod_Imp;


- (void)setUp {
    [super setUp];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // swizzle time method in MonotonicTime class
        Class montime_cls = [MonotonicTime class];
        
        SEL originalTimeSelector = @selector(time);
        
//        Method originalTimeMethod = class_getClassMethod(montime_cls, originalTimeSelector);
        IMP mockTimeMethodImp = (IMP) ___mockTime;
        char* method_types = "d@:";
        
        __originalTimeMethod_Imp = class_replaceMethod(montime_cls, originalTimeSelector, mockTimeMethodImp, method_types);
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    
}


- (void) testTicks{
    
    timenow= 1.2345678910;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:1000000000];
    int64_t val = 1.2345678910 * 1000000000;
    
    
    NSLog(@"testTicks: timenow:%f sysclock ticks %llu expected %llu",timenow, [sysclock ticks], val);
    XCTAssertEqual([sysclock ticks], val , @"sysclock ticks %llu expected %llu",[sysclock ticks], val);
    
    timenow= 2.3456789102;
    
    val = 2.3456789102 * 1000000000;
    
    
    NSLog(@"testTicks: sysclock ticks %llu expected %llu",[sysclock ticks], val);
    XCTAssertEqual([sysclock ticks], val , @"sysclock ticks %llu expected %llu",[sysclock ticks], val);
   
}


Float64 ___mockTime(id self, SEL _cmd)
{
    assert([NSStringFromSelector(_cmd) isEqualToString:@"time"]);
    return timenow;
}




- (void) testTicksPerSecond
{
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    
    XCTAssertEqual([sysclock tickRate], _kOneThousandMillion, @"tickrate not as expected");
    
}




// force subclasses to implement this method
- (void) testTime
{
    timenow= 1.2345678910;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    Float64 ticks = 1.2345678910 * _kOneThousandMillion;
    Float64 tickrate = _kOneThousandMillion;
    
    
    XCTAssertEqual([sysclock time], ticks/tickrate, @"time %f not as expected %f", [sysclock time], ticks/tickrate);
    
    NSLog(@"time: %f  expected: %f", [sysclock time], ticks/tickrate);
    

}

- (void) testNanoSeconds{
    
    timenow= 1.2345678910;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    Float64 ticks = 1.2345678910 * _kOneThousandMillion;
    Float64 tickrate = _kOneThousandMillion;
    
    
    XCTAssertEqual([sysclock time], ticks/tickrate, @"time %f not as expected %f", [sysclock time], ticks/tickrate);
    
    NSLog(@"time: %f  expected: %f", [sysclock time], ticks/tickrate);
}




- (void) testComputeTime{
    
    timenow= 1.2345678910;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    Float64 ticks = 91248752;
    
    XCTAssertEqual([sysclock computeTime:ticks], 91248752/1000000000.0, @"time %f not as expected %f", [sysclock computeTime:ticks], 91248752/1000000000.0);
    NSLog(@"time: %f  expected: %f", [sysclock computeTime:ticks], 91248752/1000000.0);
}



- (void) testComputeTimeTwo{
    
    timenow= 1.23456789115;
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
//    Float64 ticks = 91248752;
   
    int64_t nowTicks = [sysclock ticks];
    Float64 nowNanos = [sysclock ticksToNanoSeconds:nowTicks];
    Float64 nowTicksToHostNanos = [sysclock computeTimeNanos:nowTicks];
    
    
    
    
    NSLog(@"ticksNow = %llu, system clock time: %lf, host time: %lf ", nowTicks, nowNanos, nowTicksToHostNanos);
    XCTAssertEqual(nowNanos,nowTicksToHostNanos, @"ticksNow = %llu, system clock time: %lf, host time: %lf ", nowTicks, nowNanos, nowTicksToHostNanos);
    
    
    
    
    
    
//    XCTAssertEqual([sysclock computeTime:ticks], 91248752/1000000000.0, @"time %f not as expected %f", [sysclock computeTime:ticks], 91248752/1000000000.0);
//    NSLog(@"time: %f  expected: %f", [sysclock computeTime:ticks], 91248752/1000000.0);
}


- (void) testToParentTicks
{
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    XCTAssertThrows([sysclock toParentTicks:12345678910], @"Exception not thrown");
}

- (void) testFromParentTicks
{
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    XCTAssertThrows([sysclock toParentTicks:12345678910], @"Exception not thrown");

   
}





#pragma host time methods

- (void) testHostTime
{
    
    XCTAssert(YES, @"Pass");
}



- (void)dealloc
{
    Class montime_cls = [MonotonicTime class];
    
    SEL originalTimeSelector = @selector(time);
    char* method_types = "d@:";
    class_replaceMethod(montime_cls, originalTimeSelector, __originalTimeMethod_Imp, method_types);
}



@end
