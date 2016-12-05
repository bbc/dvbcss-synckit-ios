//
//  MonotonicTimeTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 31/03/2015.
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
#import <mach/mach_time.h>
#import "MonotonicTime.h"
#include <sys/types.h> // for timeval
#include <sys/time.h>

@interface MonotonicTimeTests : XCTestCase

@property (nonatomic, strong) MonotonicTime *mtime;

@end

@implementation MonotonicTimeTests
{
    // dividers
    Float64 dividerSecs;
    Float64 dividerMillis;
    Float64 dividerMicros;
    Float64 dividerNanos;
}


- (void)setUp {
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    
    self.mtime = [[MonotonicTime alloc] init];
    XCTAssertNotNil(self.mtime, @"Cannot create MonotonicTime instance");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testMonotonicTime {
    
    struct timeval startTime;
    struct timeval endTime;
    
    struct timespec sleeptime;
    
    Float64 mStartTime;
    Float64 mEndTime;
    Float64 mTimeDiff;
    int64_t timeDiff;
    
    sleeptime.tv_sec = 5;
    sleeptime.tv_nsec = 0;
    
    mStartTime = [self.mtime timeMicros];
    gettimeofday(&startTime, NULL);
    
    nanosleep(&sleeptime, NULL);
    
    mEndTime = [self.mtime timeMicros];
    gettimeofday(&endTime, NULL);
    
    mTimeDiff = mEndTime - mStartTime;
    timeDiff = timevaldiff(&endTime, &startTime);
    
    int diff = mTimeDiff - timeDiff;
    
   
    XCTAssertLessThan(abs(diff), 10000, @"PASS");
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}


int timevaldiff(struct timeval *starttime, struct timeval *finishtime)
{
    int64_t res;
    
    // Sanity check
    if (starttime && finishtime)
    {
        res = starttime->tv_sec;
        res = ((res - finishtime->tv_sec) * 1000000 + starttime->tv_usec - finishtime->tv_usec);
        return (int) res;
    }
    return -1;
}

@end
