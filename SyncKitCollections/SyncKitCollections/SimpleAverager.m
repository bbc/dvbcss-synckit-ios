//
//  SimpleAverager.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 15/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
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

#import "SimpleAverager.h"
#import "Node.h"
#import <pthread.h>

/** private node class for SimpleAverager's internal linked-list (for queue) */
@interface OffsetTuple : Node

    /** a measurement to average */
    @property (nonatomic, readwrite) uint64_t offset;
    /** the weight of the measurement to the moving average */
    @property (nonatomic, readwrite) float_t weight;

@end

@implementation OffsetTuple
{
    

    
    
}

@synthesize offset;
@synthesize weight;

@end





@implementation SimpleAverager
{
    Node *first, *last;
    pthread_mutex_t lock;
    
}

@synthesize count = _count;
@synthesize capacity = _capacity;

- (id) init
{
    self = [super init];
    if (self != nil) {
        _count = 0;
        _capacity = 10;
        first = nil;
        last = nil;
        pthread_mutex_init(&lock, NULL);
    }
    return self;

}

- (id) initWithCapacity:(int32_t)capacity__
{
    
    self = [super init];
    if (self != nil) {
        _count = 0;
        _capacity = capacity__;
        first = nil;
        last = nil;
         pthread_mutex_init(&lock, NULL);
    }
    return self;

    
}

- (void) dealloc
{
    Node* node;
    while(first!=nil)
    {
        node = first;
        first = first.next;
        
        free((__bridge void *)(node));
    }
    
    first = nil;
    last = nil;
    pthread_mutex_destroy(&lock);

}


/**
 Add a new item to averager's FIFO list. Keep adding to end of queue until max capacity os reached.
 Then, remove the oldest member (remove from front) and add the new tuple
 */
-  (uint64_t)  put:(uint64_t) offset Dispersion:(float_t) dispersion {
    
    Node* node = nil;
    OffsetTuple* temp;
    
    OffsetTuple* tuple = [[OffsetTuple alloc] init];
    tuple.offset = offset;
    tuple.weight = 1/dispersion;
    tuple.next = nil;
    
    
    
    float_t  totalWeightedOffsets = 0;
    float_t  totalWeights = 0;
    
   
    
    pthread_mutex_lock(&lock);
    
    if (_count >= _capacity)
    {
        // remove first (oldest) item in our queue
        node  = first;
        first = first.next;
        
        if (first == nil) {
            last = nil; //Empty queue
        }
        
        _count--;
        
    }
    
    if (last != nil) {
        last.next = tuple;
    }
    if (first == nil) {
        first = tuple;
    }
    
    last = tuple;
   
    _count++;
   
    for (node=first; node!=last.next; node= node.next) {
        temp = (OffsetTuple*) node;
        totalWeightedOffsets += (temp.offset * temp.weight);
        totalWeights += (temp.weight);
    }
    
    pthread_mutex_unlock(&lock);
    
    return (totalWeightedOffsets/totalWeights);
}

/** get moving average */
- (uint64_t) getMovingAverage{
    Node* node = nil;
    OffsetTuple* temp;
    
    float_t  totalWeightedOffsets = 0;
    float_t  totalWeights = 0;
    
    
    
    pthread_mutex_lock(&lock);
    
    for (node=first; node==last.next; node= node.next) {
        temp = (OffsetTuple*) node;
        totalWeightedOffsets += (temp.offset * temp.weight);
        totalWeights += (temp.weight);
    }
    
    pthread_mutex_unlock(&lock);
    
    return (totalWeightedOffsets/totalWeights);
}



@end
