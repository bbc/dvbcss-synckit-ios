//
//  SyncKitGlobals.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 20/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
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

#import "SyncKitGlobals.h"
#import "ConfigReader.h"


@implementation SyncKitGlobals
{
    
    ConfigReader* config;
    
    
}


@synthesize ClientWCPrecisionInNanos =  _ClientWCPrecisionInNanos;
@synthesize ClientWCFrequencyError = _ClientWCFrequencyError;
@synthesize SyncAccuracyTargetMilliSecs = _SyncAccuracyTargetMilliSecs;
@synthesize ServerWCPrecisionInNanos = _ServerWCPrecisionInNanos;
@synthesize ServerWCFrequencyError = _ServerWCFrequencyError;
@synthesize CachedWCREQTimeOutUSecs = _CachedWCREQTimeOutUSecs;
@synthesize CachedWCRESPTimeOutUSecs = _CachedWCRESPTimeOutUSecs;
@synthesize SocketSelectTimeOutUSecs = _SocketSelectTimeOutUSecs;
@synthesize WCREQSendPeriodUSecs = _WCREQSendPeriodUSecs;
@synthesize WCRTTThresholdMSecs = _WCRTTThresholdMSecs;

/**
 method to get singleton for this class
 */
+ (SyncKitGlobals *)getInstance {
    static SyncKitGlobals *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SyncKitGlobals alloc] init];
    });
    return instance;
}


- (id) init
{
    self = [super init];
    if (self != nil) {
        config = [ConfigReader getInstance];
        
        assert(config!=nil);

        [self loadDeviceConstants];
        
    }
    
    return self;
}


- (void) loadDeviceConstants
{
    self.ClientWCPrecisionInNanos = [config LongIntegerForKey:@"CLIENT_WC_PRECISION" defaultValue:0];
    self.ClientWCFrequencyError = [config unsignedIntegerForKey:@"CLIENT_WC_FREQ_ERROR" defaultValue:0];
    
    self.CachedWCREQTimeOutUSecs = [config unsignedIntegerForKey:@"CACHED_WC_REQ_TIMEOUT_US" defaultValue:2000000];
    self.CachedWCRESPTimeOutUSecs = [config unsignedIntegerForKey:@"CACHED_WC_RESP_TIMEOUT_US" defaultValue:1000000];
    self.SyncAccuracyTargetMilliSecs = [config unsignedIntegerForKey:@"SYNC_ACCURACY_TARGET_MS" defaultValue:0];
    self.SocketSelectTimeOutUSecs = [config unsignedIntegerForKey:@"SOCK_SELECT_TIMEOUT_US" defaultValue:1000];
    self.WCREQSendPeriodUSecs = [config unsignedIntegerForKey:@"WC_REQ_SEND_PERIOD_US" defaultValue:1000000];
    
    self.ciiURL = [config stringForKey:@"CII_URL" defaultValue:@"ws://rd35628.rd.bbc.co.uk:7681"];
    self.mrsURL = [config stringForKey:@"MRS_URL" defaultValue:@"http://bbc.co.uk/MRS"];
    self.wcURL = [config stringForKey:@"WC_URL" defaultValue:@"udp://rd35628.rd.bbc.co.uk:6677"];
    self.tsURL = [config stringForKey:@"TS_URL" defaultValue:@"ws://rd35628.rd.bbc.co.uk:7682"];
    self.teURL = [config stringForKey:@"TE_URL" defaultValue:@"ws://rd35628.rd.bbc.co.uk:7681/"];
    self.tweetURL = [config stringForKey:@"TWEET_URL" defaultValue:@"http://demo.mobile.kw.bbc.co.uk/tweetdemo/index_ios.html"];
    
    self.DIAL_AppDiscoveryTimeoutSecs = [config unsignedIntegerForKey:@"DIAL_APP_DISCOVERY_TIMEOUT_SECS" defaultValue:30];
    self.ServiceCacheRefreshIntervalSecs = [config unsignedIntegerForKey:@"SERVICE_CACHE_REFRESH_INTERVAL_SECS" defaultValue:60];
    self.ServiceSearchIntervalSecs = [config unsignedIntegerForKey:@"SSDP_SEARCH_INTERVAL_SECS" defaultValue:60];
    
    self.serviceTimeOutSecs = [config unsignedIntegerForKey:@"SERVICE_EXPIRY_TIMEOUT_SECS" defaultValue:10];
    self.WCRTTThresholdMSecs =[config unsignedIntegerForKey:@"WCPROTO_RTT_THRESH_MS" defaultValue:200];
    
}



@end
