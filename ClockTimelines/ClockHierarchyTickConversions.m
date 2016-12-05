//
//  ClockHierarchyTickConversions.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 28/05/2015.
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


@interface ClockHierarchyTickConversions : XCTestCase

@end

@implementation ClockHierarchyTickConversions
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
        IMP mockTimeMethodImp = (IMP) ClockHierarchyTickConversions_mocktime;
        char* method_types = "d@:";
        
        __originalTimeMethod_Imp = class_replaceMethod(montime_cls, originalTimeSelector, mockTimeMethodImp, method_types);
    });
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    Class montime_cls = [MonotonicTime class];
    
    SEL originalTimeSelector = @selector(time);
    char* method_types = "d@:";
    class_replaceMethod(montime_cls, originalTimeSelector, __originalTimeMethod_Imp, method_types);

}


// --- test methods ----

- (void)testNoCommonAncestor {
    
    CorrelatedClock *a1, *a2, *b1, *b2;
    NSError *error;
    
    timenow = 5020.80f;
    
    // our clock hierarchy
    SystemClock *a = [[SystemClock alloc] initWithTickRate:1000000];
    SystemClock *b = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel = [CorrelationFactory create:0 Correlation:0];
    
    a1 = [[CorrelatedClock alloc] initWithParentClock:a TickRate:1000 Correlation:&corel];
    b1 = [[CorrelatedClock alloc] initWithParentClock:b TickRate:1000 Correlation:&corel];
    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:1000 Correlation:&corel];
    b2 = [[CorrelatedClock alloc] initWithParentClock:b1 TickRate:1000 Correlation:&corel];
    
    // check clock a
    [a toOtherClock:b Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [a toOtherClock:b1 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [a toOtherClock:b2 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    
    // check clock a1
    [a1 toOtherClock:b Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [a1 toOtherClock:b1 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [a1 toOtherClock:b2 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);

    // check clock a2
    [a2 toOtherClock:b Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [a2 toOtherClock:b1 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [a2 toOtherClock:b2 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);

    
    
    // check clock b
    [b toOtherClock:a Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [b toOtherClock:a1 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [b toOtherClock:a2 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    
    // check clock b1
    [b1 toOtherClock:a Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [b1 toOtherClock:a1 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [b1 toOtherClock:a2 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    
    // check clock b2
    [b2 toOtherClock:a Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [b2 toOtherClock:a1 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    [b2 toOtherClock:a2 Ticks:5 WithError:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NoCommonAncestorClockError);
    NSLog(@"Error: %@", [error localizedDescription]);
    
    
}


- (void) testImmediateParent
{
    CorrelatedClock *a1, *a2;
    NSError *error;
    
    timenow = 5020.80f;
    
    // our clock hierarchy
    SystemClock *a = [[SystemClock alloc] initWithTickRate:1000000];
   
    Correlation corel_a1 = [CorrelationFactory create:50 Correlation:0];
    a1 = [[CorrelatedClock alloc] initWithParentClock:a TickRate:100 Correlation:&corel_a1];
    
    Correlation corel_a2 = [CorrelationFactory create:28 Correlation:999];
    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:78 Correlation:&corel_a2];
    
    XCTAssertEqual([a1 toOtherClock:a Ticks:500 WithError:&error], [a1 toParentTicks:500]);
    XCTAssertNil(error);
    NSLog(@"a1.toOtherTicks(a): %lld", [a1 toOtherClock:a Ticks:500 WithError:&error]);
    
 
//    int64_t t = [a2 toParentTicks:500];
//    int64_t t2 = [a2 toOtherClock:a1 Ticks:500 WithError:&error];
    
    XCTAssertEqual([a2 toOtherClock:a1 Ticks:500 WithError:&error], [a2 toParentTicks:500]);
    XCTAssertNil(error);
    NSLog(@"a2.toOtherTicks(a1): %lld", [a2 toOtherClock:a1 Ticks:500 WithError:&error]);

}


- (void) testDistantParent
{
    CorrelatedClock *a1, *a2;
    NSError *error;
    
    timenow = 5020.80f;
    
    // our clock hierarchy
    SystemClock *a = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel_a1 = [CorrelationFactory create:50 Correlation:0];
    a1 = [[CorrelatedClock alloc] initWithParentClock:a TickRate:100 Correlation:&corel_a1];
    
    Correlation corel_a2 = [CorrelationFactory create:28 Correlation:999];
    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:78 Correlation:&corel_a2];
    
    XCTAssertEqual([a2 toOtherClock:a Ticks:500 WithError:&error], [a1 toParentTicks:[a2 toParentTicks:500]]);
    XCTAssertNil(error);
    NSLog(@"a2.toOtherTicks(a): %lld", [a2 toOtherClock:a Ticks:500 WithError:&error]);
    
//    int64_t t = [a2 toParentTicks:500];
//   int64_t t1 = [a1 toParentTicks:[a2 toParentTicks:500]];
//   int64_t t2 = [a2 toOtherClock:a Ticks:500 WithError:&error];
}


-(void) testDistantParentMidHierarchy
{
    CorrelatedClock *a1, *a2, *a3, *a4;
    NSError *error;
    
    timenow = 5020.80f;
    
    // our clock hierarchy
    SystemClock *a = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel_a1 = [CorrelationFactory create:50 Correlation:0];
    a1 = [[CorrelatedClock alloc] initWithParentClock:a TickRate:100 Correlation:&corel_a1];
    
    Correlation corel_a2 = [CorrelationFactory create:28 Correlation:999];
    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:78 Correlation:&corel_a2];

    Correlation corel_a3 = [CorrelationFactory create:5 Correlation:1003];
    a3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:178 Correlation:&corel_a3];
    
    Correlation corel_a4 = [CorrelationFactory create:17 Correlation:9];
    a4 = [[CorrelatedClock alloc] initWithParentClock:a3 TickRate:28 Correlation:&corel_a4];
    
    XCTAssertEqual([a3 toOtherClock:a1 Ticks:500 WithError:&error], [a2 toParentTicks:[a3 toParentTicks:500]]);
    XCTAssertNil(error);
    
    NSLog(@"a3.toOtherClockTicks(a1,500): %lld", [a3 toOtherClock:a1 Ticks:500 WithError:&error]);
    
    
}



-(void) testDifferentBranches
{
    CorrelatedClock *a1, *a2, *a3, *a4, *b3, *b4;
    NSError *error;
    
    timenow = 5020.80f;
    
    // our clock hierarchy
    SystemClock *a = [[SystemClock alloc] initWithTickRate:1000000];
    
    Correlation corel_a1 = [CorrelationFactory create:50 Correlation:0];
    a1 = [[CorrelatedClock alloc] initWithParentClock:a TickRate:100 Correlation:&corel_a1];
    
    Correlation corel_a2 = [CorrelationFactory create:28 Correlation:999];
    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:78 Correlation:&corel_a2];
    
    Correlation corel_a3 = [CorrelationFactory create:5 Correlation:1003];
    a3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:178 Correlation:&corel_a3];
    
    Correlation corel_a4 = [CorrelationFactory create:17 Correlation:9];
    a4 = [[CorrelatedClock alloc] initWithParentClock:a3 TickRate:28 Correlation:&corel_a4];
    
    Correlation corel_b3 = [CorrelationFactory create:10 Correlation:20];
    b3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:1000 Correlation:&corel_b3];
    
    Correlation corel_b4 = [CorrelationFactory create:15 Correlation:90];
    b4 = [[CorrelatedClock alloc] initWithParentClock:b3 TickRate:2000 Correlation:&corel_b4];
    
    int64_t ticks = [a4 toParentTicks:500];
    ticks = [a3 toParentTicks:ticks];
    ticks = [b3 fromParentTicks:ticks];
    ticks = [b4 fromParentTicks:ticks];
    
    
    XCTAssertEqual([a4 toOtherClock:b4 Ticks:500 WithError:&error], ticks);
    XCTAssertNil(error);
    
    NSLog(@"a4.toOtherClockTicks(b4,500): %lld", [a4 toOtherClock:b4 Ticks:500 WithError:&error]);

}


-(void) testSpeedChangePropagates
{
    CorrelatedClock *a1, *a2, *a3, *a4, *b3, *b4;
        timenow = 5.0f;
    
    // our clock hierarchy
    SystemClock *a = [[SystemClock alloc] initWithTickRate:1000];
    
    Correlation corel_a1 = [CorrelationFactory create:50 Correlation:0];
    a1 = [[CorrelatedClock alloc] initWithParentClock:a TickRate:1000 Correlation:&corel_a1];
    
    Correlation corel_a2 = [CorrelationFactory create:28 Correlation:999];
    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:100 Correlation:&corel_a2];
    
    Correlation corel_a3 = [CorrelationFactory create:5 Correlation:1003];
    a3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:50 Correlation:&corel_a3];
    
    Correlation corel_a4 = [CorrelationFactory create:1000 Correlation:9];
    a4 = [[CorrelatedClock alloc] initWithParentClock:a3 TickRate:25 Correlation:&corel_a4];
    
    Correlation corel_b3 = [CorrelationFactory create:500 Correlation:20];
    b3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:1000 Correlation:&corel_b3];
    
    Correlation corel_b4 = [CorrelationFactory create:15 Correlation:90];
    b4 = [[CorrelatedClock alloc] initWithParentClock:b3 TickRate:2000 Correlation:&corel_b4];
    
    int64_t at1 = a.ticks;
    int64_t a1t1 = a1.ticks;
    int64_t a2t1 = a2.ticks;
//    int64_t a3t1 = a3.ticks;
//    int64_t a4t1 = a4.ticks;
    int64_t b3t1 = b3.ticks;
    int64_t b4t1 = b4.ticks;
    
    a3.speed = 0;
    timenow = 6.0f; // time advanced by 1 second
    
    int64_t at2 = a.ticks;
    int64_t a1t2 = a1.ticks;
    int64_t a2t2 = a2.ticks;
    int64_t a3t2 = a3.ticks;
    int64_t a4t2 = a4.ticks;
    int64_t b3t2 = b3.ticks;
    int64_t b4t2 = b4.ticks;
    
    XCTAssertEqual(at2,  at1 + 1000, @"a still advances.");      // a still advances
    XCTAssertEqual(a1t2, a1t1 + 1000, @"a1 still advances.");    // a1 still advances
    XCTAssertEqual(a2t2, a2t1 + 100, @"a2 still advances.");     // a2 still advances
    XCTAssertEqual(a3t2, 1003, @"a3 speed is zero.");            // a3 speed is zero, it is now at correlation point
    XCTAssertEqual(a4t2, 10, @"a4 speed is zero.");            // a4 is speed zero, a3.ticks is 3 ticks from correlation point for a4, translating to 1.5 ticks from a4 correlation point at its tickRate
    XCTAssertEqual(b3t2,  b3t1 + 1000, @"b3 still advances.");
    XCTAssertEqual(b4t2,  b4t1 + 2000, @"b4 still advances.");
    

}



// ------------------- utility methods ---------------
Float64 ClockHierarchyTickConversions_mocktime(id self, SEL _cmd)
{
    assert([NSStringFromSelector(_cmd) isEqualToString:@"time"]);
    return timenow;
}



- (void)dealloc
{
    }

@end
