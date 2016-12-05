//
//  ControlTimestamp.m
//
//  Created by   on 09/10/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "ControlTimestamp.h"

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

NSString *const kCrtlTimestampContentTime = @"contentTime";
NSString *const kCrtlTimestampWallClockTime = @"wallClockTime";
NSString *const kCrtlTimestampTimelineSpeedMultiplier = @"timelineSpeedMultiplier";



//------------------------------------------------------------------------------
#pragma mark - ControlTimestamp interface extensions
//------------------------------------------------------------------------------
@interface ControlTimestamp ()

/**
 *  get object for key from dictionary
 *
 *  @param aKey a key
 *  @param dict target dictionary
 *
 *  @return value for key
 */
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end



//------------------------------------------------------------------------------
#pragma mark - ControlTimestamp implementation
//------------------------------------------------------------------------------

@implementation ControlTimestamp

@synthesize contentTime = _contentTime;
@synthesize wallClockTime = _wallClockTime;
@synthesize timelineSpeedMultiplier = _timelineSpeedMultiplier;



//------------------------------------------------------------------------------
#pragma mark - Factory methods
//------------------------------------------------------------------------------
+ (instancetype)ControlTimestampWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}


//------------------------------------------------------------------------------
#pragma mark - Initialisation methods
//------------------------------------------------------------------------------
- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.contentTime = [self objectOrNilForKey:kCrtlTimestampContentTime fromDictionary:dict];
            self.wallClockTime = [self objectOrNilForKey:kCrtlTimestampWallClockTime fromDictionary:dict];
            self.timelineSpeedMultiplier = [[self objectOrNilForKey:kCrtlTimestampTimelineSpeedMultiplier fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

//------------------------------------------------------------------------------
#pragma mark -  Converter methods
//------------------------------------------------------------------------------
- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.contentTime forKey:kCrtlTimestampContentTime];
    [mutableDict setValue:self.wallClockTime forKey:kCrtlTimestampWallClockTime];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timelineSpeedMultiplier] forKey:kCrtlTimestampTimelineSpeedMultiplier];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

//------------------------------------------------------------------------------

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self toDictionary]];
}

//------------------------------------------------------------------------------
#pragma mark - Helper Method
//------------------------------------------------------------------------------
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

//------------------------------------------------------------------------------
#pragma mark - NSCoding Protocol Methods
//------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.contentTime = [aDecoder decodeObjectForKey:kCrtlTimestampContentTime];
    self.wallClockTime = [aDecoder decodeObjectForKey:kCrtlTimestampWallClockTime];
    self.timelineSpeedMultiplier = [aDecoder decodeDoubleForKey:kCrtlTimestampTimelineSpeedMultiplier];
    return self;
}

//------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_contentTime forKey:kCrtlTimestampContentTime];
    [aCoder encodeObject:_wallClockTime forKey:kCrtlTimestampWallClockTime];
    [aCoder encodeDouble:_timelineSpeedMultiplier forKey:kCrtlTimestampTimelineSpeedMultiplier];
}

//------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
    ControlTimestamp *copy = [[ControlTimestamp alloc] init];
    
    if (copy) {

        copy.contentTime = [self.contentTime copyWithZone:zone];
        copy.wallClockTime = [self.wallClockTime copyWithZone:zone];
        copy.timelineSpeedMultiplier = self.timelineSpeedMultiplier;
    }
    
    return copy;
}

//------------------------------------------------------------------------------

@end
