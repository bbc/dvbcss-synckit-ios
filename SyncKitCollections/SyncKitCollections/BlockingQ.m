//
//  BlockingQ.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 15/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.


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

#import "BlockingQ.h"
#import <pthread.h>
#import "utils.h"
#include <sys/time.h>

@implementation BlockingQ

- (BlockingQ*) init {
    if ((self = [super init])) {
        last = nil;
        first = nil;
        pthread_mutex_init(&lock, NULL);
        pthread_cond_init(& notEmpty, NULL);
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
    pthread_cond_destroy(& notEmpty);
}

- (void) put: (Node*) obj {
    pthread_mutex_lock(&lock);
    
    
    if (last != nil) {
        last.next = obj;
    }
    if (first == nil) {
        first = obj;
    }
    
    last = obj;
    
    pthread_cond_signal(& notEmpty);
    pthread_mutex_unlock(&lock);
}

- (id) take: (uint32_t) timeout {
   
    struct timeval now;
    struct timespec ts;
    Node* node=nil;
    
    
    pthread_mutex_lock(&lock);
    
    gettimeofday(&now, NULL);
    
    ts.tv_sec = now.tv_sec + (timeout/1000);
    ts.tv_nsec = (now.tv_usec * 1000) + ((timeout%1000) *1000000) ;
    
    
    while (first == nil) {
        if (pthread_cond_timedwait(& notEmpty, &lock, &ts) == ETIMEDOUT) {
            pthread_mutex_unlock(&lock);
            return nil;
        }
    }
    node  = first;
    first = first.next;
    
    if (first == nil) {
        last = nil; //Empty queue
    }
    
    pthread_mutex_unlock(&lock);
    
    return node;
}



@end
