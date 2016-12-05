//
//  MockDependent.m
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


#import "MockDependent.h"
#import <XCTest/XCTest.h>
#import "CorrelatedClock.h"
@implementation MockDependent



- (id) init
{
    
    self = [super init];
    if (self != nil) {
        self.notifications = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
     if ([keyPath isEqualToString:@"tickRate"]) {
        NSLog(@"tickRate of clock object changed.");
        NSLog(@"%@", change);
    }
    
    if ([keyPath isEqualToString:@"speed"]) {
        NSLog(@"Speed of clock was changed.");
        NSLog(@"%@", change);
    }
    
    if ([keyPath isEqualToString:@"correlation"]) {
        NSLog(@"correlation was changed.");
    }
    
    if ([keyPath isEqualToString:@"startTicks"]) {
        NSLog(@"startTicks was changed.");
         NSLog(@"%@", change);
    }
    
    
    [self.notifications addObject:change];
}


- (void) assertNotified:(NSArray*) changes
{

   
//    
//    for (UInt32 i=0; i<[self.notifications count]; i++) {
//        NSDictionary *changeDict = [changes objectAtIndex:i];
//        NSDictionary *notifDict = [md1.notifications objectAtIndex:i];
//        
//        NSNumber *oldTicks_1 = [changeDict valueForKey:@"old"];
//        NSNumber *oldTicks_2 = [notifDict valueForKey:@"old"];
//        XCTAssertEqual([oldTicks_1 unsignedLongLongValue], [oldTicks_2 unsignedLongLongValue], @"Pass");
//        
//        NSNumber *newTicks_1 = [changeDict valueForKey:@"new"];
//        NSNumber *newTicks_2 = [notifDict valueForKey:@"new"];
//        XCTAssertEqual([newTicks_1 unsignedLongLongValue], [newTicks_2 unsignedLongLongValue], @"Pass");
//    }

    
}





@end
