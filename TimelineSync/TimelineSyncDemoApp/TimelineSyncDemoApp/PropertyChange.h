//
//  PropertyChange.h
//  TimelineSyncDemoApp
//
//  Created by Rajiv Ramdhany on 20/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//

#import <Foundation/Foundation.h>

//------------------------------------------------------------------------------
#pragma mark - Class definition
//------------------------------------------------------------------------------
@interface PropertyChange: NSObject

//------------------------------------------------------------------------------
#pragma mark - properties
//------------------------------------------------------------------------------
@property (nonatomic, strong) NSString* propName;
@property (nonatomic, strong) NSMutableDictionary *change;

//------------------------------------------------------------------------------
#pragma mark - methods
//------------------------------------------------------------------------------

- (id) initWithName:(NSString*) pname oldValue:(id) oldval NewValue:(id) newval;

//------------------------------------------------------------------------------

- (BOOL) isEqualTo:(PropertyChange*) pchg;

//------------------------------------------------------------------------------

@end

