//
//  TimelineProperties.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 07/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Class for "Timeline Properties". See DVB Sepcs Section 5.5.9.5
 */
@interface TimelineProperties : NSObject

@property (nonatomic, readwrite) NSNumber *unitsPerTick;
@property (nonatomic, readwrite) NSNumber *unitsPerSecond;
@property (nonatomic, readwrite) NSNumber *accuracy;


@end
