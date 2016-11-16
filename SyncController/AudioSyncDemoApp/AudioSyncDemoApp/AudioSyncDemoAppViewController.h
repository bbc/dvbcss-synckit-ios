//
//  ViewController.h
//  AudioSyncDemoApp
//
//  Created by Rajiv Ramdhany on 20/04/2016.
//  Copyright © 2016 BBC RD. All rights reserved.
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



#import <UIKit/UIKit.h>
#import <WallClockClient/WallClockClient.h>
#import <ClockTimelines/ClockTimelines.h>
#import <TimelineSync/TimelineSync.h>
#import <AudioPlayerEngine/EZAudio.h>
#import <SyncController/SyncController.h>



@interface AudioSyncDemoAppViewController : UIViewController

@property (nonatomic, readonly) SystemClock             *sysCLK;
@property (nonatomic, readonly) TunableClock            *wallclock;
@property (nonatomic, readonly) id<IWCAlgo>             algorithm;          // an algorithm for processing candidate measurements
@property (nonatomic, readonly) id<IFilter>             filter;             // a filter to reject unsuitable candidate measurements
@property (nonatomic, readonly) NSMutableArray          *filterList;        // a filter list
@property (nonatomic, readonly) WallClockSynchroniser   *wallclock_syncer;  // a wallclock synchronisation
@property (nonatomic, readonly) CorrelatedClock         *tvPTSTimeline;     // a PTS timeline, selector = "urn:dvb:css:timeline:pts", tickrate =90000
@property (nonatomic, readonly)TimelineSynchroniser     *tvPTSTimelineSyncer;

@property (nonatomic, readonly) AudioPlayerViewController  *audioPlayerVC;

@property (nonatomic) NSArray* bufferedRange;



@end

