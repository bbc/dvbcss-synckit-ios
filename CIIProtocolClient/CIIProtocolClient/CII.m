//
//  CII.m
//  TVCompanion
//
//  Created by Rajiv Ramdhany on 15/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import "CII.h"
#import "TimelineProperties.h"
#import <SimpleLogger/SimpleLogger.h>

//------------------------------------------------------------------------------
#pragma mark - constants
//------------------------------------------------------------------------------

NSString * const kprotocolVersion               = @"protocolVersion";
NSString * const kMRSUrl                        = @"mrsUrl";
NSString * const kcontentId                     = @"contentId";
NSString * const kcontentIdStatus               = @"contentIdStatus";
NSString * const kpresentationStatus            = @"presentationStatus";
NSString * const kwcUrl                         = @"wcUrl";
NSString * const ktsUrl                         = @"tsUrl";
NSString * const ktimelines                     = @"timelines";
NSString * const ktimelineSelector              = @"timelineSelector";
NSString * const ktimelineProperties            = @"timelineProperties";
NSString * const kunitsPerTick                  = @"unitsPerTick";
NSString * const kunitsPerSecond                = @"unitsPerSecond";
NSString * const kaccuracy                      = @"accuracy";


//------------------------------------------------------------------------------
#pragma mark - interface extension
//------------------------------------------------------------------------------
@interface CII()
{
    
}

@end



//------------------------------------------------------------------------------
#pragma mark - CII implementation
//------------------------------------------------------------------------------
@implementation CII
{
    
}

//------------------------------------------------------------------------------
#pragma mark - Initialiser, lifecycle methods
//------------------------------------------------------------------------------
- (id) initWithJSONString:(NSString*) json
{
    self = [super init];
    
    
    if (self != nil)
    {
        _timelines = [[NSMutableArray alloc] init];
    
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e=nil;
        
        // parse JSON
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        if (e) {
            MWLogError(@"Error parsing CII message: %@", e);
            
            return nil;
        }
        
        _protocolVersion = [jsonDict objectForKey:kprotocolVersion];
        _msrUrl = [jsonDict objectForKey:kMRSUrl];
        _contentId = [jsonDict objectForKey:kcontentId];
        _contentIdStatus = [jsonDict objectForKey:kcontentIdStatus];
        _presentationStatus = [jsonDict objectForKey:kpresentationStatus];
        _wcUrl = [jsonDict objectForKey:kwcUrl];
        _tsUrl = [jsonDict objectForKey:ktsUrl];
        NSArray* timelines_array = [jsonDict objectForKey:ktimelines];
        
        
        
        if (timelines_array)
        {
            [_timelines removeAllObjects];
            
            for (NSDictionary *dict in timelines_array)
            {
                TimelineOption *timeOpt = [[TimelineOption alloc] init];
                timeOpt.timelineSelector = [dict objectForKey:ktimelineSelector];
                
                NSDictionary* timelinePropertiesDict = [dict objectForKey:ktimelineProperties];
                if (timelinePropertiesDict) {
                    TimelineProperties *props = [[TimelineProperties alloc] init];
                    props.unitsPerTick = [timelinePropertiesDict objectForKey:kunitsPerTick];
                    props.unitsPerSecond = [timelinePropertiesDict objectForKey:kunitsPerSecond];
                    props.accuracy = [timelinePropertiesDict objectForKey:kaccuracy];
                    
                    timeOpt.timelineProperties = props;
                }
                [_timelines addObject:timeOpt];
            }
        }
    }
    
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    _protocolVersion = nil;
    _msrUrl = nil;
    _contentId = nil;
    _presentationStatus = nil;
    _wcUrl = nil;
    _tsUrl = nil;
    [_timelines removeAllObjects];
    _timelines = nil;

}
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (TimelineOption*) timelineLookUp:(NSString*) timelineSel
{
    for (id timeline in self.timelines) {
        
        TimelineOption *timelineOpt = (TimelineOption*) timeline;
        
        if ([timelineOpt.timelineSelector caseInsensitiveCompare:timelineSel])
            return timelineOpt;
    }
    return nil;
}

//------------------------------------------------------------------------------

@end
