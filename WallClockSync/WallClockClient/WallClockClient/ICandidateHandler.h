//
//  ICandidateFilter.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 19/08/2014.
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
#import "Candidate.h"


/** Interface for recipient object of Candidate measurements */
@protocol ICandidateHandler <NSObject>

/** Adds this candidate measurement to the recipient's queue and return */
- (void) enqueueCandidate:(Candidate*) candidate;

/** Get wait time for sending next Wall Clock Sync Request message*/
- (uint32_t) getNextRequestWaitTime;

/** Get time between useful candidates */
- (uint64_t) getTimeBetweenUsefulCandidates;

@end

