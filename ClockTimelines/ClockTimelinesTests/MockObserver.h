//
//  MockObserver.h
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

#import <Foundation/Foundation.h>

@interface MockObserver : NSObject

@property (strong, nonatomic) NSMutableArray *notifications;

/**
 *  Check if changes have been received as notifications by observer
 *
 *  @param changes a list of PropertyChange objects, each representing a propery value change
 *
 *  @return true if changes match notifications
 */
- (BOOL) checkNotified:(NSArray*) changes;

/**
 *  Check if no notifications have been received by observer
 *  @param changes a list of PropertyChange objects, each representing a propery value change
 *
 *  @return true if no notifications received.
 */
- (BOOL) checkNotNotified:(NSArray*) changes;



@end



@interface PropertyChange: NSObject

@property (nonatomic, strong) NSString* propName;
@property (nonatomic, strong) NSMutableDictionary *change;

- (id) initWithName:(NSString*) pname oldValue:(id) oldval NewValue:(id) newval;


- (BOOL) isEqualTo:(PropertyChange*) pchg;
@end