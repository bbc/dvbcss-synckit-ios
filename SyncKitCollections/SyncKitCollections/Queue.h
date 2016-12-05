//
//  Queue.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 01/10/2014.


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

#import <Foundation/Foundation.h>
#import "Node.h"

/** A thread-safe Queue implementation using a linked-list*/
@interface Queue : NSObject
{
@private
    
    Node *first, *last;
}



/** initialise the queue*/
- (id) init;

/** A thread-safe operaiton to put a container object of (sub)type Node in the queue. 
 @param obj An object which is a subtype of Node */
- (void) put: (Node* ) obj;

/**  A thread-safe operation to remove the first item in the queue
 */
- (id) take;

@end
