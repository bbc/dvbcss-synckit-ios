//
//  NSStack.m
//  
//
//  Created by Rajiv Ramdhany on 24/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

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

#import "NSStack.h"

@interface NSStack()

    @property (nonatomic, strong) NSMutableArray *objects;

@end


@implementation NSStack


@synthesize objects = _objects;

#pragma mark -

- (id)init {
    if ((self = [self initWithArray:nil])) {
    }
    return self;
}

- (id)initWithArray:(NSArray*)array {
    if ((self = [super init])) {
        _objects = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}

- (void)dealloc
{
    [_objects removeAllObjects];
    _objects= nil;
}


#pragma mark - Custom accessors

- (NSUInteger)count {
    return _objects.count;
}


#pragma mark -

- (void)pushObject:(id)object {
    if (object) {
        [_objects addObject:object];
    }
}

- (void)pushObjects:(NSArray*)objects {
    for (id object in objects) {
        [self pushObject:object];
    }
}

- (id)popObject {
    if (_objects.count > 0) {
        id object = [_objects objectAtIndex:(_objects.count - 1)];
        [_objects removeLastObject];
        return object;
    }
    return nil;
}

- (id)peekObject {
    if (_objects.count > 0) {
        id object = [_objects objectAtIndex:(_objects.count - 1)];
        return object;
    }
    return nil;
}


#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_objects countByEnumeratingWithState:state objects:buffer count:len];
}


@end
