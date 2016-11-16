//
//  SystemClockNoSwizzleTests.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 14/05/2015.
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
@interface SystemClockNoSwizzleTests : XCTestCase

@end

@implementation SystemClockNoSwizzleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testPrecision
{
    
    SystemClock *sysclock = [[SystemClock alloc] initWithTickRate:_kOneThousandMillion];
    
    double precision = [sysclock estimatePrecision:1000];
    
    NSLog(@"Clock precision in secs: %g", precision);
    NSLog(@"Clock precision in nanos: %g", precision * _kOneThousandMillion);
    
    // verify that we are getting at least micro-second precision from this clock
    XCTAssertLessThanOrEqual(precision, 0.000001);
    
    
}

@end
