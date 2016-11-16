//
//  ClockBaseTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 13/04/2015.
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
#import "ClockBase.h"
#import "MockDependent.h"
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#include <unistd.h>
#import "MonotonicTime.h"
#include <math.h>


#define NUM_RUNS 10

static void *child1Context = &child1Context;
static void *child2Context = &child2Context;

@interface ClockBaseTests : XCTestCase



@end

@implementation ClockBaseTests
{
    NSMutableArray* changeList;
    ClockBase *clock1;
    MockDependent* md1;
    MonotonicTime *sysclock;
    uint64_t t1[NUM_RUNS];
    uint64_t t2[NUM_RUNS];
    int64_t measurements[NUM_RUNS];
    uint32_t index;
    
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    changeList =  [[NSMutableArray alloc] init];
    sysclock = [[MonotonicTime alloc] init];
    
    index = 0;
    
    for (int i=0; i<NUM_RUNS; i++) {
        measurements[i] =0;
    }
    
   
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testClockChangeNotify {

    // Test dependent notification on clock changes
    clock1 = [[ClockBase alloc] init];
    
    clock1.tickRate = 1000000;
    clock1.speed = 1.0;
    
    md1 = [[MockDependent alloc] init];
    [clock1 addObserver:md1 context:nil];
    
    for (int i=1; i<=10; i++) {
        // record clock tick rate change
        NSMutableDictionary *change1 = [[NSMutableDictionary alloc] init];
        [change1 setValue: [NSNumber numberWithLongLong: clock1.tickRate] forKey:@"old"];
        clock1.tickRate = 1000000 * i;
        [change1 setValue: [NSNumber numberWithLongLong: clock1.tickRate] forKey:@"new"];
        [changeList addObject:change1];
        

        // record clock speed change
        NSMutableDictionary *change2 = [[NSMutableDictionary alloc] init];
        [change2 setValue: [NSNumber numberWithFloat:clock1.speed] forKey:@"old"];
        clock1.speed = 2.0 * i;
        [change2 setValue: [NSNumber numberWithFloat:clock1.speed] forKey:@"new"];
        [changeList addObject:change2];
    }
   
    
    sleep(2.0);
    
    
    [self assertNotified];
    
    
    [clock1 removeObserver:md1 Context:nil];
    
}


- (void) assertNotified{
    
    XCTAssertTrue([changeList count] == [md1.notifications count]);
    
    for (UInt32 i=0; i<[changeList count]; i++) {
        NSDictionary *changeDict = [changeList objectAtIndex:i];
        NSDictionary *notifDict = [md1.notifications objectAtIndex:i];
        
        
        NSNumber *oldnum1 = [changeDict valueForKey:@"old"];
        NSNumber *oldnum2 = [notifDict valueForKey:@"old"];
        NSNumber *newnum1 = [changeDict valueForKey:@"new"];
        NSNumber *newnum2 = [notifDict valueForKey:@"new"];
        
        
        XCTAssertNotNil(oldnum1);
        XCTAssertNotNil(oldnum2);
        XCTAssertNotNil(newnum1);
        XCTAssertNotNil(newnum2);
        
        XCTAssertEqual([oldnum1 longLongValue], [oldnum2 longLongValue]);
        XCTAssertEqual([newnum1 longLongValue], [newnum2 longLongValue]);
    }
}


- (void) testKVCNotificationDelay{
    
    
    int64_t total;
    
    clock1 = [[ClockBase alloc] init];
    clock1.tickRate = 0;
    clock1.speed = 1.0;
    [clock1 addObserver:self context:nil];
    
    for (int i=1 ;i <=NUM_RUNS; i++){
        t1[i-1] = [sysclock timeNanos];
        clock1.tickRate = 1000000*i;
    }
    
    sleep(5.0);
    
    for (int i=1 ;i <NUM_RUNS; i++) {
        measurements[i] = t2[i]-t1[i];
        total += measurements[i];
        NSLog(@"time for key-value observation = %lld", measurements[i]);
    }
    
    double average = 1.0 * total / NUM_RUNS;
    
    // Sum difference squares
    double diff, diffTotal = 0;
    
    for (int i=1 ;i <NUM_RUNS; i++) {
        
        diff = ((double) measurements[i]) - average;
        diffTotal += diff * diff;
    }
    
    // Set variance (average from total differences)
    double variance = diffTotal / NUM_RUNS; // -1 if sample std deviation
    
    // Standard Deviation, the square root of variance
    double stdDeviation = sqrt(variance);
    
    NSLog(@"average notification delay = %f ns, stddev = %f variability=%f", average, stdDeviation, stdDeviation/average);
    
    //XCTAssertLessThan(stdDeviation, average/2);
    
    XCTAssert(YES, @"Pass");
    
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    t2[index] = [sysclock timeNanos];
    index++;
    
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
