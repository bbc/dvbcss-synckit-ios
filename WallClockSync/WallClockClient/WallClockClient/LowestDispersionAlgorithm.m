 //
//  LowestDispersionAlgorithm.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 30/09/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//
#import <pthread.h>
#import "LowestDispersionAlgorithm.h"
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SyncKitCollections/SyncKitCollections.h>
#import <SimpleLogger/SimpleLogger.h>
#import "SendPolicy.h"

@interface LowestDispersionAlgorithm()
{

    
}

/**
 *  The current best Candidate measurement seen by this algorithm.
 */
@property (nonatomic, readwrite) Candidate* bestCandidate;

@end

@implementation LowestDispersionAlgorithm
{
    Candidate               *last_candidate; // last received candidate
    Candidate               *prev_best_candidate; // previous best candidate
    TunableClock            *wallclock;
    SyncKitGlobals          *devinfo;
    int64_t                 current_offset;
    int64_t                 target_accuracy_nanos; // max tolerable dispersion
    Queue*                  wcSendPolicyList;
    SendPolicy*             currentPolicy;
    pthread_mutex_t         current_policy_mutex;
    int64_t                 best_cand_exp_time;
    uint64_t                usefulCandidatesCount;
    uint64_t                candidatesCount;
}
@synthesize bestCandidate = _bestCandidate;



#pragma mark initialisation and deallocation routines


- (id)initWithWallClock:(TunableClock*) wall_clock
{
    self = [super init];
    if (self != nil) {

        _bestCandidate = nil;
        last_candidate = nil;
        wallclock = wall_clock;
        assert(wallclock!=nil);
        devinfo = [SyncKitGlobals getInstance];
        assert(devinfo!=nil);
        current_offset = 0;
        target_accuracy_nanos = ((int64_t) [devinfo SyncAccuracyTargetMilliSecs]) * 1000000;
        assert(target_accuracy_nanos > 0);
        wcSendPolicyList = [[Queue alloc] init];
        currentPolicy = nil;
        pthread_mutex_init(&current_policy_mutex, NULL);
        best_cand_exp_time =0;
        usefulCandidatesCount= 0;
        candidatesCount = 0;
        
        // bootstrapping
        [wcSendPolicyList put:[[SendPolicy alloc] init:20 WaitTimeUSeconds:100000]]; // send WC requests at 100ms for 5 secs
    }
    return self;
}


- (void)dealloc
{
    _bestCandidate = nil;
    last_candidate =  nil;
    prev_best_candidate = nil;
    wallclock = nil;
    devinfo = nil;
    wcSendPolicyList = nil;
    currentPolicy = nil;
    pthread_mutex_destroy(&current_policy_mutex);
}



#pragma mark IWCAlgo protocol methods 

- (int64_t) processMeasurement:(Candidate*) candidate
{
    int64_t best_dispersion_now =0;
    int64_t best_offset =0;
   
    assert(wallclock!=nil);
    
    if (candidate == nil) return 0;
    
    // rollover counters
    
    candidatesCount= (candidatesCount + 1)  % 1000000;
    if (candidatesCount == 1) usefulCandidatesCount = 0;
    
    
    // get a timestamp
    int64_t now = [wallclock nanoSeconds];
    
    // pit new candidate against our best candidate
    if (_bestCandidate == nil)
    {
        prev_best_candidate = _bestCandidate;
        _bestCandidate = candidate;
        current_offset = [_bestCandidate getOffset];
       
        
        
//        MWLogDebug(@"LowestDispersionAlgorithm:  wallclock time BEFORE adjustment =%lld", [wallclock nanoSeconds]);
        [wallclock adjustTimeNanos:current_offset];
        
        wallclock.available = YES;
//        MWLogDebug(@">>>>>>>>>>>>>>>>>>> Add offset %lld", current_offset);
//        MWLogDebug(@"LowestDispersionAlgorithm:  wallclock time AFTER adjustment =%lld", [wallclock nanoSeconds]);
       
        best_dispersion_now = [_bestCandidate getDispersionAtTime:now];
        best_offset =  [_bestCandidate getOffset];
        
//        MWLogDebug(@" current_dispersion=%10f \t best_dispersion = %10f  \t best_offset = %17lld   \t wallclock time=%17llu", (float) best_dispersion_now/1000000 ,(float)best_dispersion_now/1000000, best_offset, [wallclock nanoSeconds]);
    }else
    {
        // calculate current dispersion values for new and best candidates
        int64_t new_dispersion_now = [candidate getDispersionAtTime:now];
        
        best_dispersion_now = [_bestCandidate getDispersionAtTime:now];

        if (llabs(best_dispersion_now) > new_dispersion_now)
        {
            prev_best_candidate = _bestCandidate;
            _bestCandidate = candidate;
            current_offset = [_bestCandidate getOffset];
//             MWLogDebug(@"LowestDispersionAlgorithm:  wallclock time BEFORE adjustment =%lld", [wallclock nanoSeconds]);
            
            
            int64_t errorNanos = _bestCandidate.RTT/2 + _bestCandidate.wcServerPrecisionInNanos
                                    + wallclock.parent.errorRate * (_bestCandidate.responseTime - _bestCandidate.originateTime)/1000000
                                    + _bestCandidate.wcServerMaxFreqError * (_bestCandidate.transmitTime - _bestCandidate.receiveTime)/1000000;
            
            [wallclock adjustTimeNanos:current_offset WithStaticError:errorNanos AndErrorRate:_bestCandidate.wcServerMaxFreqError];
            
//            MWLogDebug(@">>>>>>>>>>>>>>>>>>> Add offset %lld", current_offset);
//            MWLogDebug(@"LowestDispersionAlgorithm:  wallclock time AFTER adjustment =%lld", [wallclock nanoSeconds]);
            usefulCandidatesCount++;
        }
        //else
        //do nothing
        
        best_offset = [_bestCandidate getOffset];
//      MWLogDebug(@"current_dispersion=%10f ms \t best_dispersion = %10f ms \t best_offset = %10lld   \t wallclock time=%10lld", (float) new_dispersion_now/1000000 ,(float)best_dispersion_now/1000000, best_offset, [wallclock nanoSeconds]);

    }
    
    
//    // decide on next send policy if one is not ongoing
//    
//    best_cand_exp_time = [_bestCandidate getCandidateExpirationTime:target_accuracy_nanos];
//    
//    // if best candidate's dispersion has not yet grown out of bounds and we are hitting sync target accuracy
//    // then wait and send request
//    if ((now < best_cand_exp_time) && ([_bestCandidate initialDispersion] < target_accuracy_nanos))
//    {
//        wait_time = (uint32_t) (best_cand_exp_time - now)/1000;
//        
//        [wcSendPolicyList put:[[SendPolicy alloc] init:1 WaitTimeUSeconds: wait_time]];
//    
//    }else if ((now > best_cand_exp_time) || ([_bestCandidate initialDispersion] > target_accuracy_nanos)){
//        
//        pthread_mutex_lock(&current_policy_mutex);
//        
//        if (currentPolicy==nil) {
//            [wcSendPolicyList put:[[SendPolicy alloc] init:20 WaitTimeUSeconds:100000]];
//        }
//        
//        pthread_mutex_unlock(&current_policy_mutex);
//        
//    }
//    MWLogDebug(@"LowestDispersionAlgorithm: candidate count: %lld useful candidates:%lld", candidatesCount, usefulCandidatesCount);
    return best_offset;
}


/** get best dispersion at current time*/
- (int64_t) getCurrentDispersion{
    
    if (_bestCandidate!=nil)
        return [_bestCandidate getDispersionAtTime:[wallclock nanoSeconds]];
    else{
        
        return 0;
    }
}

/** get best offset */
- (int64_t) getCandidateOffset
{
    return current_offset;
}

/** get wait time for next request */
- (uint32_t) getNextReqWaitTime
{
//    uint32_t wait_time;
//    
//    pthread_mutex_lock(&current_policy_mutex);
//    if  (currentPolicy == nil)
//        currentPolicy = [wcSendPolicyList take];
//    
//    
//    if (currentPolicy != nil)
//    {
//        if (currentPolicy.count > 0)
//        {
//            currentPolicy.count--;
//            wait_time = currentPolicy.waitTimeUSecs;
//        }
//        else // policy has expired, get a new one
//            currentPolicy = nil;
//    }
//    
//    if  (currentPolicy == nil)
//        wait_time = [devinfo WCREQSendPeriodUSecs]; // default wait time
//    else
//        wait_time = currentPolicy.waitTimeUSecs;
//    
//    pthread_mutex_unlock(&current_policy_mutex);
//    return wait_time;
    
    return 120000;
}


- (Candidate*) getBestCandidate
{
    return self.bestCandidate;
}


- (int64_t) timeBetweenUsefulCandidatesNanos
{
    
    if ((prev_best_candidate) && (_bestCandidate))
    {
        return (_bestCandidate.responseTime - prev_best_candidate.responseTime );
    }else
        return -1;
    
}


- (float) usefulCandidatesPercent
{
    if (candidatesCount>0) {
        return ((usefulCandidatesCount*1.0)/candidatesCount)*100.0;
    }
    else
        return 0.0;
    
    
}



@end
