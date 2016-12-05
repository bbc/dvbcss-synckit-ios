//
//  WallClockClientComponent.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 12/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
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

#import "WallClockSynchroniser.h"
#import "LowestDispersionAlgorithm.h"
#import "RTTThresholdFilter.h"



@interface WallClockSynchroniser ()

// readwrite access redefinition
@property (nonatomic, readwrite) NSString* WCServerHost;
@property (nonatomic, readwrite) int port;
@property (nonatomic, strong, readwrite) WCProtocolClient *wcProtoClient;
@property (nonatomic, strong, readwrite) CandidateSink *candidateHandler;
@property (nonatomic, strong, readwrite) id<IWCAlgo> algorithm;
@property (nonatomic, strong, readwrite) NSMutableArray *filters;



@end



@implementation WallClockSynchroniser
{
    NSMutableArray *filterList_tmp;
    
}

-(instancetype)initWithWCServer:(NSString *)address Port:(int)port WallClock:(TunableClock *)wallclock
{
    self = [super init];
    if (self) {
        
        assert(wallclock !=nil);
        
        self.algorithm = [[LowestDispersionAlgorithm alloc] initWithWallClock:wallclock];
        
        
        filterList_tmp = [[NSMutableArray alloc] init];
        [filterList_tmp addObject:[[RTTThresholdFilter alloc] initWithThreshold:200]];
        self.filters = filterList_tmp;
        
    }
    return [self initWithWCServer:address Port:port WallClock:wallclock Algorithm:self.algorithm FilterList:self.filters];
}


- (instancetype) initWithWCServer:(NSString*) address
                             Port:(int) port
                        WallClock:(TunableClock*) wallclock
                        Algorithm:(id<IWCAlgo>) algo
                       FilterList:(NSArray*) filters
{
    self = [super init];
    if (self) {
        
        assert(algo !=nil);
        
        self.algorithm = algo;
        
        if (filters !=nil){
            if ([self passIFilterCheck:filters])
                self.filters = filters;
        }
        
        self.candidateHandler = [[CandidateSink alloc] initWith:wallclock
                                                      Algorithm:self.algorithm
                                                     AndFilters:self.filters];
        
        self.wcProtoClient = [[WCProtocolClient alloc] initWithHost:address
                                                               Port:port
                                                      CandidateSink:self.candidateHandler
                                                       AndWallClock:wallclock];
    }
    return self;

}



- (BOOL) passIFilterCheck: (NSArray*) filterlist
{
    bool pass = true;
    
    for (id obj in filterlist)
        pass = pass && ([obj conformsToProtocol:@protocol(IFilter)]);
    
    return pass;
}



/**
 *  Start WallClock time synchronisation
 */
- (void) start
{
    [self.candidateHandler start];
    [self.wcProtoClient start];
}

/**
 * Pause WallClock time synchronisation. To restart, call start method
 */
- (void) pause
{
    [self.candidateHandler stop];
    [self.wcProtoClient stop];
}

/**
 *  Stop WallClock time synchronisation
 */
- (void) stop
{
    [self.candidateHandler stop];
    [self.wcProtoClient stop];
    
}


/**
 *  Get the percentage of bad candidate measurements i.e. candidates rejected by filters
 *
 *  @return percentage of bad candidate measurements
 */
- (float) getCandidatesDroppedPercent
{
    uint64_t total = 0;
    uint64_t dropped = 0;
    
    id<IFilter> filter;
    
    
    // get total candidates ingressing into filter pipeline
    // this is the counter in the first filter
    if (!self.filters) return 0.0;

    if ([self.filters count] > 0)
    {
        filter = [self.filters firstObject];
        total  =  [filter getCandidateTotal];
        
        for (id<IFilter> tmp in self.filters) {
            dropped += [tmp getCandidateDropCount];
        }
        
        // avoid division by zero
        if (total > 0)
            return ((dropped *1.0)/total)*100;
        else
            return 0.0;
    }
    return 0.0;
 }

/**
 *  Get the percentage of candidate measurements that led to a wallclock time readjustment.
 *
 *  @return percentage of useful candidate measurements
 */
- (float) getUsefulCandidatesPercent
{
    if ([self.algorithm respondsToSelector:@selector(usefulCandidatesPercent)]) {
        return [self.algorithm usefulCandidatesPercent];
    }else
        return 0.0;
}


/**
 *  Get time between candidates that caused a WallClock time adjustment
 *
 *  @return time in nanoseconds
 */
- (int64_t) getTimeBetweenUsefulCandidates
{
    
    if ([self.algorithm respondsToSelector:@selector(timeBetweenUsefulCandidatesNanos)]) {
        return [self.algorithm timeBetweenUsefulCandidatesNanos];
    }else
        return -1;
}


/**
 *  Get the current dispersion of the best candidate.
 *
 *  @return the currently best dispersion value in nanoseconds
 */
- (int64_t) getCurrentDispersion
{
    int64_t dispersion;
    if (self.algorithm) {
        dispersion=  [self.algorithm getCurrentDispersion];
        return dispersion;
    }
    return -1;
}


/**
 *  get best offset
 *
 *  @return get best candidate's offset
 */
- (int64_t) getCandidateOffset
{
    if (self.algorithm) {
        return [self.algorithm getCandidateOffset];
    }
    return -1;
}



/**
 *  Get the current best candidate seen by the algorithm.
 *
 *  @return the current best candidate (a Candidate object)
 */
- (Candidate*) getBestCandidate
{
    
    if (self.algorithm) {
        return [self.algorithm getBestCandidate];
    }
    return nil;
}



@end
