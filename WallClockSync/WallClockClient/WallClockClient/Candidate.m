//
//  CandidateM.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 13/08/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import "Candidate.h"
#import <SyncKitConfiguration/SyncKitConfiguration.h>
#import <SyncKitCollections/utils.h>
#import <SimpleLogger/SimpleLogger.h>



@interface Candidate()

@property (nonatomic, weak) SyncKitGlobals* config;

@end



@implementation Candidate
{
    uint64_t wcClientPrecisionInNanos;
    uint32_t wcClientFreqError;
   
}

@synthesize config = _config;



#pragma mark Initialisation

- (id)initWithResponseMsg:(WCSyncMessage*) response_msg Quality: (int8_t) quality TimeIsNanos:(BOOL) is_nanos
{
    WCSyncMessagePkt *pkt;
    _config = [SyncKitGlobals getInstance];
    
    
    self = [super init];
    if (self != nil) {
        
        _responseMsg = response_msg;
        _responseTime =  [response_msg responseTimeNanos];
        pkt = response_msg.packet;
       
         _originateTime = ((int64_t) ntohl(pkt->originate_timevalue.timevalue_secs)) * 1000000000 + (int64_t) ntohl(pkt->originate_timevalue.timevalue_nanos);
        
        _receiveTime = ((int64_t) ntohl(pkt->receive_timevalue.timevalue_secs)) * 1000000000 + (int64_t) ntohl(pkt->receive_timevalue.timevalue_nanos);
        
        _transmitTime = ((int64_t) ntohl(pkt->transmit_timevalue.timevalue_secs)) * 1000000000 + (int64_t) ntohl(pkt->transmit_timevalue.timevalue_nanos);
        
        _nanos = is_nanos;
        
        // get client precision and frequency error from device config
        wcClientPrecisionInNanos = _config.ClientWCPrecisionInNanos;
        wcClientFreqError = _config.ClientWCFrequencyError;
        
        // get server  precision and frequency error from message
        if (_config.ServerWCPrecisionInNanos == 0)
        {
           _config.ServerWCPrecisionInNanos = pow(2,  (int8_t) pkt->precision) * 1000000000  ; // server wall clock precision in nanos
        }
        _wcServerPrecisionInNanos = pow(2,  (int8_t) pkt->precision) * 1000000000  ;
        
        if (_config.ServerWCFrequencyError ==0 )
            _config.ServerWCFrequencyError = ntohl(pkt->max_freq_error) / 256;

        _wcServerMaxFreqError = ntohl(pkt->max_freq_error) / 256;
        
        _quality = quality;
        
        
        // calculate the offset value
        int64_t diff = ((_receiveTime +  _transmitTime) - (_responseTime + _originateTime));
        _offset =  diff / 2 ; 
        
        // calculate round trip time
        _RTT =  (_responseTime - _originateTime) - (_transmitTime - _receiveTime);
        
        // calculate initial value for dispersion at the time of measurement
         _initialDispersion = [self getDispersionAtTime:_responseTime];
//         MWLogDebug(@"offset=%f ms \t     RTT = %f ms \t     Dispersion = %f ms", (float)_offset/1000000,  (float) _RTT/1000000, (float)_initialDispersion / 1000000);
    }
    return self;
}


/**
 Cleanup code
 */
- (void) dealloc{
    _config = nil;
    //free(_responseMsg.packet);
    _responseMsg = nil;
}




#pragma mark Computation methods
- (int64_t) getOffset
{
    if(_offset == 0)
    {
        int64_t diff = ((_receiveTime +  _transmitTime) - (_responseTime + _originateTime));
        _offset =  diff / 2 ;
    }
    return _offset;
}


- (int64_t) getRTT
{
    if (_RTT ==0)
        _RTT = (_responseTime - _originateTime) - (_transmitTime - _receiveTime);
    
    return _RTT;
}


- (int64_t) getDispersionAtTime:(int64_t) time
{
     return ( _wcServerPrecisionInNanos
            + ( _wcServerMaxFreqError * (_transmitTime - _receiveTime)
              + wcClientFreqError * (_responseTime - _originateTime)
              + (wcClientFreqError + _wcServerMaxFreqError) * (time - _responseTime)
              )/1000000 + _RTT/2);
    
}


- (int64_t) getCandidateExpirationTime:(int64_t) accuracy_target_nanos
{
    if (accuracy_target_nanos > _initialDispersion)
           return _responseTime + ((accuracy_target_nanos - _initialDispersion) * (1/(1000*(wcClientFreqError + _wcServerMaxFreqError))));
    else
        return _responseTime;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Candidate: offset=%f ms \t     RTT = %f ms \t     Dispersion = %f ms", (float)_offset/1000000,  (float) _RTT/1000000, (float)_initialDispersion / 1000000];
}


@end
