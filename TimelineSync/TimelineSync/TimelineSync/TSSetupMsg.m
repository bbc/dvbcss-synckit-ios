//
//  TSSetupMsg.m
//  Companion_Screen_App
//
//  Created by Rajiv Ramdhany on 09/10/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import "TSSetupMsg.h"



//------------------------------------------------------------------------------
#pragma mark - TSSetupMsg implementation
//------------------------------------------------------------------------------

@implementation TSSetupMsg


//------------------------------------------------------------------------------
#pragma mark - Lifecycle methods: Initialization, Dealloc, etc
//------------------------------------------------------------------------------

- (id) init:(NSString*) contentid_stem TimelineSel:(NSString*) timeline_selector
{
  
    if ((self = [super init])) {
        _contentIdStem = contentid_stem;
        _timelineSelector = timeline_selector;
    }
    return self;
}

//------------------------------------------------------------------------------

- (void)dealloc
{
    
    
}
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark -  (De-)Serialisation Methods (deprecated)
//------------------------------------------------------------------------------

////////////// USING JSONModel Library for serialisation to JSON and unserialisation from JSON  /////////////
//
//- (NSData*) toJSON
//{
//    NSDictionary *tssetup =  [NSDictionary dictionaryWithObjectsAndKeys:self.contentIdStem,kcontentIdStem, self.timelineSelector,    kTimelineSelector, nil];
//
//    NSError *error = nil;
//    NSData *json;
//    
//    // Dictionary convertable to JSON ?
//    if ([NSJSONSerialization isValidJSONObject:tssetup])
//    {
//        // Serialize the dictionary
//        json = [NSJSONSerialization dataWithJSONObject:tssetup options:0 error:&error];
//        
//        // If no errors, let's view the JSON
//        if (json != nil && error == nil)
//        {
//            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
//            
//            NSLog(@"JSON: %@", jsonString);
//            
//        }
//    }
//    
//    
//    return json;
//    
//}
//
//
//- (NSString*) toJSONString
//{
//    NSDictionary *tssetup =  [NSDictionary dictionaryWithObjectsAndKeys:self.contentIdStem,kcontentIdStem, self.timelineSelector,    kTimelineSelector, nil];
//    
//    NSError *error = nil;
//    NSData *json;
//    
//    // Dictionary convertable to JSON ?
//    if ([NSJSONSerialization isValidJSONObject:tssetup])
//    {
//        // Serialize the dictionary
//        json = [NSJSONSerialization dataWithJSONObject:tssetup options:0 error:&error];
//        
//        // If no errors, let's view the JSON
//        if (json != nil && error == nil)
//        {
//            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
//            
//            NSLog(@"JSON: %@", jsonString);
//            return jsonString;
//        }
//    }
//    
//    
//    return nil;
//    
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
