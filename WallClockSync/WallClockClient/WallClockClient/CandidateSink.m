//
//  CandidateSink.m
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

#import "CandidateSink.h"
#import <SyncKitCollections/BlockingQ.h>
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <pthread.h>
#import "Candidate.h"
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SimpleLogger/SimpleLogger.h>


@interface CandidateSink()

@property (nonatomic, readwrite) id<IWCAlgo> algorithm;
@property (nonatomic, readwrite) TunableClock* wallclockref;

// redeclare init as private to force use of explicit-value init
- (id) init;


@end

@implementation CandidateSink
{
    BlockingQ           *candidateQ;
    SyncKitGlobals       *config;
    NSThread            *QServicingThread;  // candidate processing thread
    pthread_mutex_t     mutex;          // mutex for read_to_go condition var
    BOOL                continue_loop;
    uint8_t             wcClientPrecision;
    uint32_t            wcClientMaxFreqError;
    uint64_t            target_accuracy_nanos;
    
}

@synthesize algorithm =_algorithm;
@synthesize wallclockref =_wallclockref;
@synthesize filterList = _filterList;


/**
 clean up code, called by the ARC  */
- (void) dealloc
{
    continue_loop = false;
    _algorithm = nil;
    [_filterList removeAllObjects];
    _filterList = nil;
    _wallclockref = nil;
    config = nil;
    candidateQ = nil;
    
    pthread_mutex_destroy(&mutex);
   }


- (id) init
{
    return self;
}

// see comments in .h
- (id) initWith:(TunableClock*) wall_clock Algorithm:(id<IWCAlgo>) algorithm AndFilters:(NSArray*) filter_array {
    self = [super init];
    if (self != nil) {
        
        _wallclockref = wall_clock;
        if (filter_array)
            _filterList = [[NSMutableArray alloc] initWithArray:filter_array];
        else
            _filterList = [[NSMutableArray alloc] init];
        
        _algorithm = algorithm;
        
        assert(_algorithm !=nil);
        
        candidateQ = [[BlockingQ alloc] init];
        config = [SyncKitGlobals getInstance];
        wcClientPrecision = [config ClientWCPrecisionInNanos];
        wcClientMaxFreqError = [config ClientWCFrequencyError];
        target_accuracy_nanos = ((uint64_t) [config SyncAccuracyTargetMilliSecs] * 1000000);

        pthread_mutex_init(&mutex, NULL);
        
        continue_loop = true;
        
     }
    
    return self;

}



- (id) addFilter:(id<IFilter>) filterobjref
{
    [_filterList addObject:filterobjref];
    
    return self;
}


// See comments in .h
- (void) start
{
    continue_loop = true;
    // create our send request thread
    QServicingThread =   [[NSThread alloc]
                          initWithTarget:self
                          selector:@selector(QServicingThreadFunc)
                          object:nil];
    // start the thread
    [QServicingThread start];
 }


// see comments in .h
- (void) stop
{
    continue_loop = false;
}



#pragma mark filtering process methods
/** Thread function to service the queue containing candidate measurements */
- (void) QServicingThreadFunc{
    
    Candidate* newCandidate;
    BOOL filtered = false;
    
    MWLogDebug(@"CandidateSink: QServicingThread has started.");
    do{
        
        
        newCandidate = nil;
        
        // get candidate from measurement process
        newCandidate = [candidateQ take: 2000];
        
        
        
        if (newCandidate)
        {
           // MWLogDebug(@"CandidateSink: %@", [newCandidate description]);
            
            filtered = false;

            // pass candidate through filters
            // if candidate filtered, bypass rest of loop
            for (id<IFilter> filter in _filterList) {
                if (![filter checkCandidate: newCandidate]){
                    filtered = true;
                    continue;
                }
            }
        }
        
        if (!filtered) [_algorithm processMeasurement: newCandidate];
        
        // free malloc'ed memory in the candidate's responseMsg to cleanup and discard the candidate
        free(newCandidate.responseMsg.packet);
        
        pthread_mutex_lock(&mutex);
        if (!continue_loop) {
            pthread_mutex_unlock(&mutex);
            break; // exit this loop
        }
        pthread_mutex_unlock(&mutex);

    }while(YES);
    
    // clean up before thread exits
    newCandidate =  nil;
    MWLogDebug(@"CandidateSink: QServicingThread has exited.");

}
#pragma mark ICandidateFilter methods
/** ICandidateFilter method to enqueue Candidate object in this object's blocking queue*/
- (void) enqueueCandidate:(Candidate*) candidate{
  
    if (candidateQ != nil)
        [candidateQ put:candidate];
    
}


- (uint32_t) getNextRequestWaitTime{
    
    if (_algorithm)
        return [_algorithm getNextReqWaitTime];
    else
        return [config WCREQSendPeriodUSecs];
}

- (uint64_t) getTimeBetweenUsefulCandidates{
    return 0;
}



@end
