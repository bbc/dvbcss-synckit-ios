//
//  MRSConversions.m
//  ClockTimelines
//
//  Created by Rajiv Ramdhany on 04/02/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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

#import <XCTest/XCTest.h>

#import "ClockBase.h"
#import "SystemClock.h"
#import "CorrelatedClock.h"
#import "TunableClock.h"

@interface MRSConversions : XCTestCase

@end

@implementation MRSConversions

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFindTimeOnAlaskaAssetTimeline{
    
    //Alaska computations
    SystemClock *sys_clk = [[SystemClock alloc] initWithTickRate:1000000];
    Correlation corel_tv = [CorrelationFactory create:sys_clk.ticks Correlation:2687878388];
    CorrelatedClock *tvtimeline = [[CorrelatedClock alloc] initWithParentClock:sys_clk TickRate:90000 Correlation:&corel_tv];
    
    // material timeline
    Correlation corel_mat = [CorrelationFactory create:2687878388 Correlation:0];
    CorrelatedClock *material_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_mat];
    
    
    // alaska companion video  asset
    Correlation corel_asset_mp4 = [CorrelationFactory create:2685289987 Correlation:0];
    
    CorrelatedClock *mp4_asset_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_asset_mp4];
    
    NSError *err;
    int64_t mp4_assettimeline_ticks = [material_timeline toOtherClock:mp4_asset_timeline Ticks:0 WithError:&err];
    
    NSLog(@"time on mp4 video asset timeline at material time zero is: %f s", mp4_assettimeline_ticks*1.0/1000000);
    
    
    // Premixed Audio/Audio Description asset
    
    Correlation cor_AudioAD = [CorrelationFactory create:2685304075 Correlation:0];
    
    CorrelatedClock *AudioAD_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_AudioAD];

    int64_t AudioAD_timeline_ticks = [material_timeline toOtherClock:AudioAD_timeline Ticks:0 WithError:&err];
     NSLog(@"time on AudioAD timeline at material time zero is: %f s", AudioAD_timeline_ticks*1.0/1000000);
    
    // Audio Description asset
    Correlation cor_AD = [CorrelationFactory create:2687734885 Correlation:0];
    CorrelatedClock *AD_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_AD];

    
    int64_t AD_timeline_ticks = [material_timeline toOtherClock:AD_timeline Ticks:0 WithError:&err];
    NSLog(@"time on AD timeline at material time zero is: %f s", AD_timeline_ticks*1.0/1000000);
    
    //Episode's audio track
    
    Correlation cor_Audio = [CorrelationFactory create:2687716705 Correlation:0];
    CorrelatedClock *Audio_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_Audio];
    
    
    int64_t Audio_timeline_ticks = [material_timeline toOtherClock:Audio_timeline Ticks:0 WithError:&err];
    NSLog(@"time on Audio timeline at material time zero is: %f s", Audio_timeline_ticks*1.0/1000000);
    
    
    // Wolf Hall computations
    
    
    
    
    
    
    
    
    
    

//    
//    
//    Correlation corel_asset = [CorrelationFactory create:2685289987 Correlation:0];
//    
//    CorrelatedClock *asset_timeline = [[CorrelatedClock alloc] initWithParentClock:a TickRate:90000 Correlation:&corel_mat];
//    
//    
//    
//    
//    Correlation corel_a2 = [CorrelationFactory create:28 Correlation:999];
//    a2 = [[CorrelatedClock alloc] initWithParentClock:a1 TickRate:100 Correlation:&corel_a2];
//    
//    Correlation corel_a3 = [CorrelationFactory create:5 Correlation:1003];
//    a3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:50 Correlation:&corel_a3];
//    
//    Correlation corel_a4 = [CorrelationFactory create:1000 Correlation:9];
//    a4 = [[CorrelatedClock alloc] initWithParentClock:a3 TickRate:25 Correlation:&corel_a4];
//    
//    Correlation corel_b3 = [CorrelationFactory create:500 Correlation:20];
//    b3 = [[CorrelatedClock alloc] initWithParentClock:a2 TickRate:1000 Correlation:&corel_b3];
//
//    
    
    
    
    
    
}


- (void)testFindTimeOnWolfHallAssetTimeline{
    
    //Wolf Hall computations
    SystemClock *sys_clk = [[SystemClock alloc] initWithTickRate:1000000];
    Correlation corel_tv = [CorrelationFactory create:sys_clk.ticks Correlation:2687878388];
    CorrelatedClock *tvtimeline = [[CorrelatedClock alloc] initWithParentClock:sys_clk TickRate:90000 Correlation:&corel_tv];
    
    // material timeline
    Correlation corel_mat = [CorrelationFactory create:2687878388 Correlation:0];
    CorrelatedClock *material_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_mat];
    
    
    // wolfhall companion video  asset
    Correlation corel_asset_mp4 = [CorrelationFactory create:3014239987 Correlation:0];
    
    CorrelatedClock *mp4_asset_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_asset_mp4];
    
    NSError *err;
    int64_t mp4_assettimeline_ticks = [material_timeline toOtherClock:mp4_asset_timeline Ticks:0 WithError:&err];
    
    NSLog(@"time on mp4 video asset timeline at material time zero is: %f s", mp4_assettimeline_ticks*1.0/1000000);
    
    
    // Premixed Audio/Audio Description asset
    
    Correlation cor_AudioAD = [CorrelationFactory create:3014235431 Correlation:0];
    
    CorrelatedClock *AudioAD_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_AudioAD];
    
    int64_t AudioAD_timeline_ticks = [material_timeline toOtherClock:AudioAD_timeline Ticks:0 WithError:&err];
    NSLog(@"time on AudioAD timeline at material time zero is: %f s", AudioAD_timeline_ticks*1.0/1000000);
    
    // Audio Description asset
    Correlation cor_AD = [CorrelationFactory create:3015616727 Correlation:0];
    CorrelatedClock *AD_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_AD];
    
    
    int64_t AD_timeline_ticks = [material_timeline toOtherClock:AD_timeline Ticks:0 WithError:&err];
    NSLog(@"time on AD timeline at material time zero is: %f s", AD_timeline_ticks*1.0/1000000);
    
    //Episode's audio track
    
    Correlation cor_Audio = [CorrelationFactory create:3015602554 Correlation:0];
    CorrelatedClock *Audio_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_Audio];
    
    
    int64_t Audio_timeline_ticks = [material_timeline toOtherClock:Audio_timeline Ticks:0 WithError:&err];
    NSLog(@"time on Audio timeline at material time zero is: %f s", Audio_timeline_ticks*1.0/1000000);
    
    
    // Wolf Hall web content carousel
    
    // 3014239987
    
    Correlation cor_web = [CorrelationFactory create:3014239987 Correlation:0];
    CorrelatedClock *web_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_web];
    
    
    int64_t web_timeline_ticks = [material_timeline toOtherClock:web_timeline Ticks:0 WithError:&err];
    NSLog(@"time on web timeline at material time zero is: %f s", web_timeline_ticks*1.0/1000000);
}



- (void)testFindTimeOnChannel_A_AssetsTimeline{
    
    //Channel A computations
    SystemClock *sys_clk = [[SystemClock alloc] initWithTickRate:1000000];
    Correlation corel_tv = [CorrelationFactory create:sys_clk.ticks Correlation:900000];
    CorrelatedClock *tvtimeline = [[CorrelatedClock alloc] initWithParentClock:sys_clk TickRate:90000 Correlation:&corel_tv];
    
    // material timeline
    Correlation corel_mat = [CorrelationFactory create:900000 Correlation:0];
    CorrelatedClock *material_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_mat];
    
    
    // channel A companion video  asset
    Correlation corel_asset_mp4 = [CorrelationFactory create:900000 Correlation:0];
    
    CorrelatedClock *mp4_asset_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_asset_mp4];
    
    NSError *err;
    int64_t mp4_assettimeline_ticks = [material_timeline toOtherClock:mp4_asset_timeline Ticks:0 WithError:&err];
    
    NSLog(@"time on mp4 video asset timeline at material time zero is: %f s", mp4_assettimeline_ticks*1.0/1000000);
    
    
    
    //Episode's audio track
    
    Correlation cor_Audio = [CorrelationFactory create:900000 Correlation:0];
    CorrelatedClock *Audio_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_Audio];
    
    
    int64_t Audio_timeline_ticks = [material_timeline toOtherClock:Audio_timeline Ticks:0 WithError:&err];
    NSLog(@"time on Audio timeline at material time zero is: %f s", Audio_timeline_ticks*1.0/1000000);
    
    
}


- (void)testFindTimeOnBalls_AssetsTimeline{
    
    //Channel A computations
    SystemClock *sys_clk = [[SystemClock alloc] initWithTickRate:1000000];
    Correlation corel_tv = [CorrelationFactory create:sys_clk.ticks Correlation:900000];
    CorrelatedClock *tvtimeline = [[CorrelatedClock alloc] initWithParentClock:sys_clk TickRate:90000 Correlation:&corel_tv];
    
    // material timeline
    Correlation corel_mat = [CorrelationFactory create:900000 Correlation:0];
    CorrelatedClock *material_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_mat];
    
    
    // channel A companion video  asset
    Correlation corel_asset_mp4 = [CorrelationFactory create:900000 Correlation:0];
    
    CorrelatedClock *mp4_asset_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&corel_asset_mp4];
    
    NSError *err;
    int64_t mp4_assettimeline_ticks = [material_timeline toOtherClock:mp4_asset_timeline Ticks:0 WithError:&err];
    
    NSLog(@"time on mp4 video asset timeline at material time zero is: %f s", mp4_assettimeline_ticks*1.0/1000000);
    
    
    
    //Episode's audio track
    
    Correlation cor_Audio = [CorrelationFactory create:900000 Correlation:0];
    CorrelatedClock *Audio_timeline = [[CorrelatedClock alloc] initWithParentClock:tvtimeline TickRate:1000000 Correlation:&cor_Audio];
    
    
    int64_t Audio_timeline_ticks = [material_timeline toOtherClock:Audio_timeline Ticks:0 WithError:&err];
    NSLog(@"time on Audio timeline at material time zero is: %f s", Audio_timeline_ticks*1.0/1000000);
    
    
}




- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
