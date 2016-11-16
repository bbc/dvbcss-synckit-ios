//
//  MockObserver.m
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

#import "MockObserver.h"
#import "CorrelatedClock.h"


@implementation PropertyChange

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.change = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}

- (id) initWithName:(NSString*) pname oldValue:(id) oldval NewValue:(id) newval
{
    self = [super init];
    if (self != nil) {
        self.propName = pname;
        self.change = [[NSMutableDictionary alloc] init];
        [self.change setObject:oldval forKey:@"old"];
        [self.change setObject:newval forKey:@"new"];
    }
    return self;
    
}


- (NSString*) description
{
    
    return [NSString stringWithFormat:@"Property: %@ Old Value:%@ New Value: %@", self.propName,
            [self.change objectForKey:@"old"],
            [self.change objectForKey:@"new"]];
    
}

- (BOOL) isEqualTo:(PropertyChange*) pchg
{
    BOOL sameOld = false;
    BOOL sameNew= false;
    BOOL sameProperty = ([self.propName caseInsensitiveCompare: pchg.propName] == NSOrderedSame);
    
    
    if (!sameProperty)
        return false;
    
    id oldobj_self = [self.change objectForKey:@"old"];
    id newobj_self = [self.change objectForKey:@"new"];
    
    id oldobj = [pchg.change objectForKey:@"old"];
    id newobj = [pchg.change objectForKey:@"new"];
    
    if ([oldobj isKindOfClass:[NSNumber class]] && [oldobj_self isKindOfClass:[NSNumber class]])
    {
        NSNumber *oldnum = (NSNumber*) oldobj;
        NSNumber *oldnum_self = (NSNumber*) oldobj_self;
        
        sameOld = [oldnum isEqualToNumber:oldnum_self];
     }else if ([oldobj isKindOfClass:[NSValue class]] && [oldobj_self isKindOfClass:[NSValue class]])
     {
         // this must be a correlation; everything else is a scalar data type
         Correlation oldCorel, oldCorel_self;
         [oldobj getValue:&oldCorel];
         [oldobj_self getValue:&oldCorel_self];

         // compare our correlation structs
         sameOld = (oldCorel.parentTickValue == oldCorel_self.parentTickValue);
         sameOld = sameOld && (oldCorel.tickValue == oldCorel_self.tickValue);
      }
    
    if ([newobj isKindOfClass:[NSNumber class]] && [newobj_self isKindOfClass:[NSNumber class]])
    {
        NSNumber *newnum = (NSNumber*) newobj;
        NSNumber *newnum_self = (NSNumber*) newobj_self;
        
        sameNew = [newnum isEqualToNumber:newnum_self];
    }else if ([newobj isKindOfClass:[NSValue class]] && [newobj_self isKindOfClass:[NSValue class]])
    {
        // this must be a correlation; everything else is a scalar data type
        Correlation newCorel, newCorel_self;
        [newobj getValue:&newCorel];
        [newobj_self getValue:&newCorel_self];
        
        // compare our correlation structs
        sameNew = (newCorel.parentTickValue == newCorel_self.parentTickValue);
        sameNew = sameNew && (newCorel.tickValue == newCorel_self.tickValue);
    }
    
    
    return sameOld && sameNew && sameProperty;
}

@end


@implementation MockObserver

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
    // record all observations
    PropertyChange *pchg =  [[PropertyChange alloc] initWithName:keyPath oldValue:[change valueForKey:@"old"] NewValue:[change valueForKey:@"new"]];
    [self.notifications addObject:pchg];
    NSLog(@"MockObserver: CorrelatedClock %lu property value change %@",(unsigned long)[object hash] ,[pchg description]);
    
}


- (BOOL) checkNotified:(NSArray*) changes
{
    BOOL matched= true;
    BOOL found = false;
    
    // check if changes were received as notifications by observer
    if (changes!=nil){

        for (PropertyChange *pchg in changes)
        {
            for (PropertyChange *notif in self.notifications) {
                if ([pchg isEqualTo:notif]) {
                    found = true;
                    break;
                }else
                    found = false;
            }
        }
        
        matched = matched && found;
    }
    return matched;
    
}


- (BOOL) checkNotNotified:(NSArray*) changes
{
    return ![self checkNotified:changes];
}


@end
