//
//  TSSetupMsg.h
//  Companion_Screen_App
//
//  Created by Rajiv Ramdhany on 09/10/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModelFramework/JSONModelFramework.h>


//------------------------------------------------------------------------------
#pragma mark - TSSetupMsg class
//------------------------------------------------------------------------------

/**
 Class to build a Timeline Synchronisation setup message
 Uses JSONModel library for serialisation to JSON and deserialisation from JSON.
 
 */
@interface TSSetupMsg : JSONModel

//------------------------------------------------------------------------------
#pragma mark - properties
//------------------------------------------------------------------------------

/**
 *  content id stem string
 */
@property (nonatomic, readwrite) NSString *contentIdStem;

/**
 *  Timeline Selector string
 */
@property (nonatomic, readwrite) NSString *timelineSelector;


//------------------------------------------------------------------------------
#pragma mark - Initialisation Methods
//------------------------------------------------------------------------------

/**
 init a Timeline Synschronisation setup message
 @param contentid_stem 
 @param timeline_selector
 */
- (id) init:(NSString*) contentid_stem TimelineSel:(NSString*) timeline_selector;


//------------------------------------------------------------------------------

@end




