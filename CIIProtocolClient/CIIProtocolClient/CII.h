//
//  CII.h
//  TVCompanion
//
//  Created by Rajiv Ramdhany on 15/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimelineOption.h"

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

extern NSString * const kprotocolVersion;
extern NSString * const kMRSUrl;
extern NSString * const kcontentId;
extern NSString * const kcontentIdStatus;
extern NSString * const kpresentationStatus;
extern NSString * const kwcUrl;
extern NSString * const ktsUrl;
extern NSString * const ktimelines;
extern NSString * const ktimelineSelector;
extern NSString * const ktimelineProperties;
extern NSString * const kunitsPerTick;
extern NSString * const kunitsPerSecond;
extern NSString * const kaccuracy;

//------------------------------------------------------------------------------
#pragma mark - a CII instance
//------------------------------------------------------------------------------
/**
 *  A CII class representing CII state.
 */
@interface CII : NSObject 

/**
 *  CSS-CII protocol version
 */
@property (atomic, readwrite) NSString*         protocolVersion;
/**
 *  Material Resolution Server URL
 */
@property (atomic, readwrite) NSString*         msrUrl;
/**
 *  Content Identifier for the programme currently shown on the TV
 */
@property (atomic, readwrite) NSString*         contentId;
/**
 *  The status of the ContentId as defined in DVB-CSS specifications
 */
@property (atomic, readwrite) NSString*         contentIdStatus;
/**
 *  TV content's presentation status e.g. final, or transitioning to another programme
 */
@property (atomic, readwrite) NSString*         presentationStatus;
/**
 *  CSS-WC server endpoint URL e.g. udp://xxx.xxx.xxx.xxx:yyyy
 */
@property (atomic, readwrite) NSString*         wcUrl;
/**
 *  CSS-TS server endpoint URL
 */
@property (atomic, readwrite) NSString*         tsUrl;
/**
 *  Timelines reported by TV as available for synchronisation. Each timeline object is a TimelineOption instance. 
 */
@property (atomic, readwrite) NSMutableArray*   timelines;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Initialiser
//------------------------------------------------------------------------------

/**
 *  Initialise a CII object with JSON string
 *
 *  @param json JSON message from CII server
 *
 *  @return CII instance
 */
- (id) initWithJSONString:(NSString*) json;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 *  Search for a timeline in the available timelines
 * included in the CII message
 *
 *  @param timelineSel timeline selector string
 *
 *  @return a TimelineOption object containing properties of the selected timeline.
 */
- (TimelineOption*) timelineLookUp:(NSString*) timelineSel;

//------------------------------------------------------------------------------

@end


