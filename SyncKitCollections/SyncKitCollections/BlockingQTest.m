//
//  BlockingQTest.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 15/08/2014.

//  Copyright 2015 British Broadcasting Corporation
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

#import "BlockingQTest.h"
#import "BlockingQ.h"
#import "DataNode.h"
#import <SimpleLogger/SimpleLogger.h>


@implementation BlockingQTest
{
    BlockingQ* testQ;
    
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        testQ = [[BlockingQ alloc] init];
    }
    
    return self;
}


- (void) startTest {
    //Start producer thread
    [NSThread detachNewThreadSelector:@selector(doPut) toTarget:self withObject:nil];
    //Start consumer thread
    [NSThread detachNewThreadSelector:@selector(doGet) toTarget:self withObject:nil];
}
//Producer
- (void) doPut {
    int i;
    DataNode *newNode;
    
    
    for (i = 0; i < 100; ++i) {
        @autoreleasepool {
            NSString *str = [NSString stringWithFormat: @"Data %d", i];
            MWLogDebug(@"Putting %@", str);
            
            newNode = [[DataNode alloc] init];
            [newNode setData:str];
            
            [testQ put: newNode];
         }
    }
}
//Consumer
- (void) doGet {
    
    DataNode* node;
    
    while (TRUE) {
        @autoreleasepool {
            
            node = [testQ take: 1000];
            if (node == nil) {
                MWLogDebug(@"Queue is empty");
            } else {
                //[NSThread sleepForTimeInterval: 1];
                MWLogDebug(@"Got %@", [node data]);
            }
        }
    }
}

@end
