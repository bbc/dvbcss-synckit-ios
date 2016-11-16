//
//  ViewController.m
//  CIIProtocolClientDemoApp
//
//  Created by Rajiv Ramdhany on 25/05/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
//

#import "ViewController.h"
#import <CIIProtocolClient/CIIProtocolClient.h>


NSString* const kHbbTV_InterDevSyncURL = @"ws://192.168.0.7:7681/cii";

@interface ViewController ()

@property (nonatomic, readwrite) CIIClient              *cssCIIClient;

@end

@implementation ViewController
{
    CII* currentCII;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cssCIIClient = [[CIIClient alloc] initWithCIIURL:kHbbTV_InterDevSyncURL];
    
    if (_cssCIIClient)
        [_cssCIIClient start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) registerForCIINotifications
{
    
    // --- register for CIIProtocolClient notifications ---
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIConnectionFailure object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCIINotifications:) name:kCIIDidChange object:nil];
}



- (void) handleCIINotifications:(NSNotification*) notification
{
    NSUInteger ciiChangeStatus=0;
    
    // --- 2. Handle new CII and start WallClock synchronisation ----
    
    if  ([[notification name] caseInsensitiveCompare:kCIIDidChange] == 0) {
        
        id temp = [[notification userInfo] objectForKey:kCIIDidChange];
        
        NSNumber *status = [[notification userInfo] objectForKey:kCIIChangeStatusMask];
        
        if (status) {
            ciiChangeStatus = [status unsignedIntegerValue];
        }
        
        
        if ((ciiChangeStatus & NewCIIReceived) !=0)
        {
            NSLog(@"CSSynchroniser: Received New CII notification ... ");
            
            
            if ([temp isKindOfClass:[CII class]])
            {
                currentCII = temp;
            }
        }
        
        if (ciiChangeStatus  & ContentIdChanged) {
            
            if ([temp isKindOfClass:[CII class]])
            {
                currentCII = temp;
            }
            // TODO: Handle ContentId change
            
            // content Id has changed.
            
            // 1. set SyncTimeline available= false - sync controllers will react by suspending their activity
            // 2. when they have been suspended, destroy the sync controllers
            // 3. report contentId to app via native API
            
            
            
            
            
            
            
//            dispatch_async( dispatch_get_main_queue(), ^{
//                // // // // // // // / / // /  / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
//                
//                //                if (self.TimelineSyncClientComponent) {
//                //                    MWLogDebug(@"AppDelegate: channel change detected.... stopping TSClient and starting a new TSClient with new content_id.");
//                //
//                //
//                //                    tmpTSClient = self.TimelineSyncClientComponent;
//                //                    [tmpTSClient stop];
//                //
//                //
//                //                    self.TimelineSyncClientComponent = [[TSClient alloc] initWithEndpointURL:currentCII.tsUrl ContentId:kContentId TimelineSelector:kTimelineSelector];
//                //                    [self.TimelineSyncClientComponent start];
//                //
//                //                }
//                // / / / / / /  //  / / / / / / / / / / / / / / / / / / / / // / / / / / / / / / / / / / // /
//                
//                [self.delegate CSSynchroniser:self ContentIdDidChange:currentCII.contentId];
//            });
        }
    }
    
    
    
}
@end
