//
//  CandidateSink.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 15/08/2014.
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

#import <Foundation/Foundation.h>
#import <ClockTimelines/ClockTimelines.h>
#import "ICandidateHandler.h"
#import "IWCAlgo.h"
#import "IFilter.h"


/**
 *  This class implements the WallClock protocol's Candidate measurement processing functionality.
 *  Candidate mesaurements received by the WCClient object are enqueued in the CandidateSink
 *  object for processing. A thread in this class services this queue; it takes a Candidate
 *  measurement, passes it through a number of filters (See IFilter.h) and if the measurement
 *  survives the filtering process, it then submit it to a WC algorithm object (See IWCAlgo.h)
 *  for WC offset and dispersion calculation.
 */
@interface CandidateSink : NSObject <ICandidateHandler>

/**
 *  A reference to a wallclock whose offset can be adjusted
 */
@property (nonatomic, readonly) TunableClock *wallclockref;

/**
 *  An algorithm to process Candidate instances and update the WallClock, if necessary
 */
@property (nonatomic, readonly) id<IWCAlgo> algorithm;

/**
 *  List of filters (id<IFilter>)
 */
@property (nonatomic, strong) NSMutableArray *filterList;

/**
 *  Unused initialiser
 *
 *  @return nil
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initialise the Candidate measurements handling object
 *
 *  @param wall_clock   - the WallClock for which an offset is being calculated. We are using the 
 *  feedback loop model (see pg 153 CSS Specs).
 *  @param algorithm    - an object that conforms to the IWCAlgo.h protocol e.g. LowestDispersionAlgorithm
 *  @param filter_array - a set of filters for filtering the measurements e.g. LowestDispersionFilter
 *
 *  @return initialised CandidateSink instance
 */
- (id) initWith:(TunableClock*) wall_clock Algorithm:(id<IWCAlgo>) algorithm AndFilters:(NSArray*) filter_array;

/**
 *  Add a candidate filter to this object
 *
 *  @param filterobjref - a filter object
 *
 *  @return CandidateSink instance with filter
 */
- (id) addFilter:(id<IFilter>) filterobjref;

/**
 *  Start this component
 */
- (void) start;

/**
 *  Stop this component
 */
- (void) stop;








@end
