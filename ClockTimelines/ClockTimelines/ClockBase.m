//
//  ClockBase.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 05/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
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

#import "ClockBase.h"



@interface ClockBase()


@end

NSString * const ClockErrorDomain           = @"IOS.DVB.CSS.Clock.ErrorDomain";
NSString * const kClockDidChangeTickOffset  = @"ClockDidChangeTickOffset";
NSString * const kClockDidChangeRate        = @"ClockDidChangeRate";

@implementation ClockBase

@synthesize speed = _speed;
@synthesize available = _available;


#pragma mark initialisation and description routines
///-----------------------------------------------------------
/// @name initialisation and description methods
///-----------------------------------------------------------
- (id) init
{
    self = [super init];
    if (self != nil) {
        _speed = 1.0;
        _available = true;
        self.parent = nil;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ClockBase description:\ntickRate:%llu speed: %f parent: %@",self.tickRate, self.speed, [self.parent description]];
}


- (float) getEffectiveSpeed
{
    ClockBase *clock;
    float s = 1.0;
    
    clock = self;
    while (clock != nil) {
        s = s * clock.speed;
        clock = self.parent;
    }

    return s;
}


#pragma mark class abstract methods
///-----------------------------------------------------------
/// @name abstract methods
///-----------------------------------------------------------
// force subclasses to implement this method
- (Float64) computeTime:(int64_t) ticks{
    
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}


// force subclasses to implement this method
- (Float64) computeTimeNanos:(int64_t) ticks{
    
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

// force subclasses to implement this method
- (int64_t) toParentTicks:(int64_t) ticks
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

// force subclasses to implement this method
- (int64_t) fromParentTicks:(int64_t) ticks
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}


-(int64_t)dispersionAtTime:(int64_t)timeInNanos{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

#pragma mark class  methods
///-----------------------------------------------------------
/// @name class methods
///-----------------------------------------------------------
- (int64_t) toOtherClock:(ClockBase*) otherClock
                    Ticks:(int64_t) ticks
                WithError:(NSError**) error
{
    NSMutableOrderedSet* selfAncestry = [[NSMutableOrderedSet alloc] init];
    NSMutableOrderedSet* oCLKAncestry = [[NSMutableOrderedSet alloc] init];
    NSMutableOrderedSet* intersectionSet = [[NSMutableOrderedSet alloc] init];
    
    ClockBase *child;
    int64_t i_ticks =  ticks;
    
    // get ancestry of this clock
    child = self;
    while (child != nil) {
        [selfAncestry addObject:child];
        child = child.parent;
    }
    
    // get ancestry of other clock
    child = otherClock;
    while (child != nil) {
        [oCLKAncestry addObject:child];
        child = child.parent;
    }
    
    // check if there is a common ancestor
    BOOL common = false;

    if ([selfAncestry count] > [oCLKAncestry count]){
        intersectionSet = [NSMutableOrderedSet orderedSetWithOrderedSet:selfAncestry];
        
        [intersectionSet intersectOrderedSet:oCLKAncestry];
    }
    else{
        intersectionSet = [NSMutableOrderedSet orderedSetWithOrderedSet:oCLKAncestry];
        [intersectionSet intersectOrderedSet:selfAncestry];
    }
    
    
    if ([intersectionSet count] > 0)
    {
        common = true;
        
        [selfAncestry minusOrderedSet:intersectionSet];
        [oCLKAncestry minusOrderedSet:intersectionSet];
    
        
        // now we have a path from both clocks to a common ancestor.
        // note that the lists do NOT include the common ancestor itself
            
        // 1) walk the path to the common ancestor converting tick values
        for (ClockBase* clk in selfAncestry) {
            i_ticks = [clk toParentTicks:i_ticks];
        }
        
        //2) walk the path back up from the common ancestor to the other clock, converting tick values
        NSEnumerator *reverseEnum =  [oCLKAncestry reverseObjectEnumerator];
        
        ClockBase* c;
        
        while (c=[reverseEnum nextObject]) {
            i_ticks = [c fromParentTicks:i_ticks];
        }
        
        return i_ticks;
        
    }
    else{
       
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Could not find a common ancestor to both clocks."};
            
            *error = [NSError errorWithDomain:ClockErrorDomain
                                         code:NoCommonAncestorClockError
                                     userInfo:userInfo];
       
        return 0;
    }
    
}



- (double) estimatePrecision:(NSUInteger) sampleSize
{
    NSMutableArray *diffs = [[NSMutableArray alloc] initWithCapacity:sampleSize];
    uint64_t a ;
    uint64_t b ;
    uint64_t xmin = _kOneThousandMillion;
    uint64_t x=0;
    
    for (int i=0; i<sampleSize; i++) {
        a = [self ticks];
        b = [self ticks];
        
        if (a<b) x=b-a;
        
        
        if (a<b) [diffs addObject:[NSNumber numberWithUnsignedLongLong:b-a]];
    }
   
       
    for(NSNumber *num in diffs)
    {
        x = [num unsignedLongLongValue];
        if (x<xmin) xmin=x;
    }
    
    return ((double)xmin)/self.tickRate;
}





#pragma mark ClockProtocol methods

///-----------------------------------------------------------
/// @name ClockProtocol protocol methods
///-----------------------------------------------------------
// force subclasses to implement this method
- (int64_t) ticks{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}


- (uint64_t) ticksPerSecond
{
    return self.tickRate;
}

/**
 * Get the tick count of this clock, but converted to units of nanoseconds given the current tick rate of this clock
 */
- (int64_t) nanoSeconds{
    
    Float64 result = ((Float64)[self ticks] / [self ticksPerSecond]);
    
    int64_t nanos =result * _kOneThousandMillion;
    
    //NSLog(@"Clock ticks = %llu ticksPerSecond=%llu, nanos = %llu ", [self getTicks], [self getTicksPerSecond], nanos);
    
    return nanos;
}

/**
 * Converts the supplied nanosecond to number of ticks given the current tick rate of this clock
 */
- (int64_t) nanoSecondsToTicks:(int64_t)nanos{

    Float64 result =  (Float64) ([self ticksPerSecond] * 1.0) / _kOneThousandMillion;
    
    int64_t result2 =  (result) * nanos;
    
    //1154695183119268
    //1154695183119268
    return result2;
}


/**
 * Converts the supplied number of ticks to nanoseconds given the current tick rate of this clock
 */
- (int64_t) ticksToNanoSeconds:(int64_t)ticks{
    
     return ticks * ((Float64) _kOneThousandMillion / (Float64)[self ticksPerSecond]);
}


// force subclasses to implement this method
- (CMTime) hostTime
{
    CMTime t;
    [self doesNotRecognizeSelector:_cmd];
    return t;
}


// force subclasses to implement this method
- (Float64) time
{
    [self doesNotRecognizeSelector:_cmd];
    return 0.0;
}



#pragma mark Clock Key-Value observation methods
///-----------------------------------------------------------
/// @name Clock Key-Value observation methods
///-----------------------------------------------------------
/**
 *  Add an observer for clock state changes. Uses IOS's Key-Value-Coding mechanism.
 *
 *  @param observer the observer object to be notified
 *  @param context  A context to differentiate between observed clock objects
 */
- (void) addObserver:(id) observer
             context: (void*) context
{
    [self addObserver:observer
           forKeyPath:@"tickRate"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
    
    [self addObserver:observer
           forKeyPath:@"speed"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:context];
}

/**
 *  Remove observer from this clock object
 *
 *  @param observer observer to unregister
 *  @param context context to differentiate between clock objects
 */
- (void) removeObserver:(id) observer
                Context: (void*) context
{
    [self removeObserver:observer forKeyPath:@"tickRate" context:context];
    [self removeObserver:observer forKeyPath:@"speed" context:context];
}








@end
