//
//  TunableClockSwizzlerTests.m
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
#import "SystemClock.h"
#import "TunableClock.h"
#import "MockDependent.h"

/**
 *  Tests for Tunable Clock that require a mock monotonic time object. 
 *  Our mock monotonic time object is simulated by swizzling the time method of
 *  the Monotonic time class with a mock implementation.
 */
@interface TunableClockSwizzlerTests : XCTestCase

@end

@implementation TunableClockSwizzlerTests
{
    SystemClock *sysCLK;
    TunableClock *tuneCLK_;
    NSMutableArray* changeList;
    MockDependent *md1;
}
double timenow;
static IMP __originalTimeMethod_Imp;
- (void)setUp {
    [super setUp];
     changeList =  [[NSMutableArray alloc] init];
    static dispatch_once_t onceToken;
    
    // setup our test
    
    dispatch_once(&onceToken, ^{
        
        // swizzle time method in MonotonicTime class
        Class montime_cls = [MonotonicTime class];
        
        SEL originalTimeSelector = @selector(time);
        
        //        Method originalTimeMethod = class_getClassMethod(montime_cls, originalTimeSelector);
        IMP mockTimeMethodImp = (IMP) __mockTime;
        char* method_types = "d@:";
        
        __originalTimeMethod_Imp = class_replaceMethod(montime_cls, originalTimeSelector, mockTimeMethodImp, method_types);
    });
}

- (void)tearDown {
    [super tearDown];
//    Class montime_cls = [MonotonicTime class];
//    
//    SEL originalTimeSelector = @selector(time);
//    char* method_types = "d@:";
//    class_replaceMethod(montime_cls, originalTimeSelector, __originalTimeMethod_Imp, method_types);

}

-(void) testGetParent
{
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
    XCTAssertEqualObjects(tuneCLK.parent, sysCLK);
    
}


-(void) testTicking
{
    
    timenow= 5020.8;
    
    
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
    
    for (int i=0;i<100;i++){
    
        timenow += 100.2;
        
       
        //NSLog(@"Tunable clock ticks = %llu", [tuneCLK ticks]);
        
        XCTAssertEqualWithAccuracy([tuneCLK ticks], (100.2*(i+1)*1000+5), 5);
    }
    
}


-(void) testToParentTicks
{
    
    timenow= 5020.8;
    
    
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
    tuneCLK.slew = 50;
    
    XCTAssertEqualWithAccuracy([tuneCLK toParentTicks:5+1000*50], [sysCLK ticks] + 1000000*50.0/1.050, 10);
}

-(void) testFromParentTicks
{
    timenow= 5020.8;
    
    
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
    tuneCLK.slew = 50;
    
    XCTAssertEqualWithAccuracy([tuneCLK fromParentTicks:[sysCLK ticks]+1000000*50.0/1.050], 5+1000*50, 1);
}


- (void) test_adjustTicks
{
    timenow= 5020.8;
    
    
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    TunableClock *tuneCLK = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
    timenow += 100.2;
    
    
    NSLog(@"Tunable clock ticks = %lld", [tuneCLK ticks]);
    
    XCTAssertEqual([tuneCLK ticks], 100.2*1000 +5, @"Expected tick value test passed.");
    
    [tuneCLK adjustTicks:28];
    
     XCTAssertEqual([tuneCLK ticks], 100.2 * 1000 + 5 + 28, @"Expected tick value test after adjust_ticks passed.");
    
}


-(void) testAdjustTicksNotify
{
    timenow= 5020.8;
    
    
    sysCLK = [[SystemClock alloc] initWithTickRate:1000000];
    tuneCLK_ = [[TunableClock alloc] initWithParentClock:sysCLK TickRate:1000 Ticks:5];
    
     timenow += 100.2;
    
    md1 = [[MockDependent alloc] init];
    
    [tuneCLK_ addObserver:md1 context:nil];
    
    //
    // record clock tick rate change
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    
    NSNumber *oldTicks = [NSNumber numberWithUnsignedLongLong:tuneCLK_.startTicks];
    
    
    [change setObject: oldTicks forKey:@"old"];
    [tuneCLK_ adjustTicks:28];
     XCTAssertEqual([tuneCLK_ ticks], 100.2 * 1000 + 5 + 28, @"Expected tick value test after adjust_ticks passed.");
    NSNumber *newTicks = [NSNumber numberWithUnsignedLongLong:tuneCLK_.startTicks];
    
    [change setObject: newTicks forKey:@"new"];
    // record change in changelist
    [changeList addObject:change];
    
    XCTAssertNotEqual([oldTicks unsignedLongLongValue], [newTicks unsignedLongLongValue], @"Pass");
    
    
    sleep(2.0);
    
    [self assertNotified];
    [ tuneCLK_ removeObserver:md1 Context:nil];
    
}



- (void) assertNotified{
    
    XCTAssertTrue([changeList count] == [md1.notifications count]);
    
    for (UInt32 i=0; i<[md1.notifications count]; i++) {
        NSDictionary *changeDict = [changeList objectAtIndex:i];
        NSDictionary *notifDict = [md1.notifications objectAtIndex:i];
        
        NSNumber *oldTicks_1 = [changeDict valueForKey:@"old"];
        NSNumber *oldTicks_2 = [notifDict valueForKey:@"old"];
        XCTAssertEqual([oldTicks_1 unsignedLongLongValue], [oldTicks_2 unsignedLongLongValue], @"Pass");
        
        NSNumber *newTicks_1 = [changeDict valueForKey:@"new"];
        NSNumber *newTicks_2 = [notifDict valueForKey:@"new"];
        XCTAssertEqual([newTicks_1 unsignedLongLongValue], [newTicks_2 unsignedLongLongValue], @"Pass");
    }
}





Float64 __mockTime(id self, SEL _cmd)
{
    assert([NSStringFromSelector(_cmd) isEqualToString:@"time"]);
    return timenow;
}




@end
