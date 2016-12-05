//
//  Queue.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 01/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.


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

#import "Queue.h"

@implementation Queue



- (id) init {
    if ((self = [super init])) {
        last = nil;
        first = nil;
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
    
}

- (void) put: (Node*) obj {

    @synchronized(self){
   
        if (last != nil) {
            last.next = obj;
        }
        if (first == nil) {
            first = obj;
        }
        
        last = obj;
    }
   
}

- (id) take {
    
     @synchronized(self){
        Node* node=nil;
        node  = first;
        first = first.next;
        
        if (first == nil) {
            last = nil; //Empty queue
        }
        return node;
    }
}
@end
