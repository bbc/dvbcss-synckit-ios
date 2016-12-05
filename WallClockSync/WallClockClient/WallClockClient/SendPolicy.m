//
//  SendPolicy.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 01/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "SendPolicy.h"

@implementation SendPolicy

@synthesize count = _count;
@synthesize waitTimeUSecs = _waitTimeUSecs;



- (id) init: (int) count_ WaitTimeUSeconds: (uint32_t) wait_time{
   
    if ((self = [super init])) {
        _count = count_;
        _waitTimeUSecs = wait_time;
 
        self.next = nil;
    }
    return self;
}

@end
