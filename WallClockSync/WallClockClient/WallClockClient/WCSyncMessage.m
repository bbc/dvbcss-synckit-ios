//
//  WCSyncMessage.m
//  WallClockSyncProtoClient
//
//  Created by Rajiv Ramdhany on 24/07/2014.
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

#import "WCSyncMessage.h"
#import <UDPMessaging/UDPMessaging.h>
#import <SimpleLogger/SimpleLogger.h>
#include <mach/mach_time.h>

@interface WCSyncMessage()
// private declarations

void setCurrentTimeValue(WCTimeValue* tv);

@end



@implementation WCSyncMessage
{
    BOOL malloced;
}
const uint64_t kOneThousand_Million = 1000000000;
@synthesize packet = _packet;



#pragma mark packet initialisation
- (id)initWithBuffer:(uint8_t*) buffer
{
    self = [super init];
    if (self != nil) {
        
        memset(buffer, '\0', WCSYNCMSG_SIZE);
        _packet = (WCSyncMessagePkt *) buffer;
        assert(_packet != NULL);
        
        malloced = false;
    }
    return self;
}


- (id)initWithPacket:(WCSyncMessagePkt*) packet AndResponseTimeNanos:(int64_t) response_time
{
    self = [super init];
    if (self != nil) {
        
        // allocate memory chunk, we'll have to cleanup manually i.e. not rely on ARC when cached packet is dropped.
        _packet = (WCSyncMessagePkt*) malloc(WCSYNCMSG_SIZE);
//        MWLogDebug(@"WCSyncMessage: WCSyncMsgPkt mem allocated. %d", self.hash);
        if (_packet == NULL)
        {
            return nil;
        }
        malloced = true;
        memcpy(_packet, packet, WCSYNCMSG_SIZE);
        
        _responseTimeNanos = response_time;
        
    }
    return self;
}


- (void) dealloc
{
//    if (malloced)
//        MWLogDebug(@"WCSyncMessage: packet %d deallocated", self.hash);
    
}

#pragma mark packet field setters
- (id) setVersion:(uint8_t) version
// set version of CSS-WC protocol version
{
    
    _packet->version = version;
    return self;
}

- (id) setMessageType:(uint8_t) msg_type
// set message type: see DVB CSS specs
{
    _packet->message_type = msg_type;
    return self;
}

- (id) setPrecision:(uint8_t) precision
// set precision; value of this field only set for message type 1, 2 and 3.
{
//    if ( _wcSyncMsg->message_type != CSSWC_REQ)
        _packet->precision = precision;
//    else
//        _wcSyncMsg->precision = 0;
    
    
    return self;
}

- (id) setReserved:(uint8_t) reserved
{
    _packet->reserved = reserved;
    return self;
}

- (id) setMaxFreqError:(uint32_t) max_freq_error
// set max frequency error of Wall Clock
{
//    if ( _wcSyncMsg->message_type != CSSWC_REQ)
        _packet->max_freq_error = htonl(max_freq_error);
//    else
//        _wcSyncMsg->max_freq_error = 0;
//    
    return self;
}

- (id) setOriginateTimeValueSeconds:(uint32_t) timevalue_secs AndNanoSecs:(uint32_t) timevalue_nanos
// set time value of wall clock when at WC client when a mesage type 0 is sent
{
    _packet->originate_timevalue.timevalue_secs = htonl(timevalue_secs);
    _packet->originate_timevalue.timevalue_nanos = htonl(timevalue_nanos);
    
    return self;
}

- (id) setOriginateTimeValueCurrentTime
{
    setCurrentTimeValue(&(_packet->originate_timevalue));
    
    return self;
}


- (id) setReceiveTimeValueCurrentTime
{
     setCurrentTimeValue(&(_packet->receive_timevalue));
    return self;
}

- (id) setTransmitTimeValueCurrentTime
{
     setCurrentTimeValue(&(_packet->transmit_timevalue));
    return self;
    
}


- (id) setOriginateTimeValueCurrentTime:(ClockBase *)clock
{
    setCurrentTimeValueFromClock(&(_packet->originate_timevalue), [clock nanoSeconds]);
    
    return self;
}

- (id) setOriginateTimeValue:(int64_t) clockNanos
{
    setCurrentTimeValueFromClock(&(_packet->originate_timevalue), clockNanos);
    
    return self;
}

- (id) setReceiveTimeValueCurrentTime:(ClockBase *)clock
{
    setCurrentTimeValueFromClock(&(_packet->receive_timevalue), [clock nanoSeconds] );
    return self;
}

- (id) setTransmitTimeValueCurrentTime:(ClockBase *)clock
{
    setCurrentTimeValueFromClock(&(_packet->transmit_timevalue), [clock nanoSeconds]);
    return self;
    
}


- (id) setReceiveTimeValueSeconds:(uint32_t) timevalue_secs AndNanoSecs:(uint32_t) timevalue_nanos
// set time value of wall clock at WC server when a message_type 0 is received
{
    _packet->receive_timevalue.timevalue_secs = htonl(timevalue_secs);
    _packet->receive_timevalue.timevalue_nanos = htonl(timevalue_nanos);
    
    return self;
}

- (id) setTransmitTimeValueSeconds:(uint32_t) timevalue_secs AndNanoSecs:(uint32_t) timevalue_nanos
// set time value of wall clock at WC server when message_type 1 is transmitted
{
    _packet->transmit_timevalue.timevalue_secs = htonl(timevalue_secs);
    _packet->transmit_timevalue.timevalue_nanos = htonl(timevalue_nanos);
    
    return self;
}


#pragma mark packet field getters
- (uint8_t) getVersion
{
    return _packet->version;
}

- (uint8_t) getMessageType
{
    return _packet->message_type;
}

- (uint8_t) getPrecision
{
    return _packet->precision;
}

- (uint8_t) getReserved
{
    return _packet->reserved;
}

- (uint32_t) getMaxFreqError
{
    return ntohl(_packet->max_freq_error);
}

- (WCTimeValue) getOriginateTimeValueSeconds
{
    return _packet->originate_timevalue;
}

- (int64_t) getOriginateTimeNanos
{
    return ((int64_t) ntohl(_packet->originate_timevalue.timevalue_secs)) * 1000000000 + (int64_t) ntohl(_packet->originate_timevalue.timevalue_nanos);
}

- (WCTimeValue) getReceiveTimeValueSeconds
{
    return _packet->receive_timevalue;
}

- (WCTimeValue) getTransmitTimeValueSeconds
{
    return _packet->transmit_timevalue;
}


# pragma mark utilty methods
- (void) dump
// display message
{
    MWLogInfo(@"Message: version = [%u], msg_type = [%u], precision = [%u], reserved = [%u] max_freq_error = [%u]", _packet->version, _packet->message_type, _packet->precision, _packet->reserved, _packet->max_freq_error);
    MWLogInfo(@"originate_timevalue_secs = [%u] originate_timevalue_nanos = [%u]", _packet->originate_timevalue.timevalue_secs, _packet->originate_timevalue.timevalue_nanos);
    MWLogInfo(@"receive_timevalue_secs = [%u] receive_timevalue_nanos = [%u]", _packet->receive_timevalue.timevalue_secs, _packet->receive_timevalue.timevalue_nanos);
    MWLogInfo(@"transmit_timevalue_secs = [%u] response_timevalue_nanos = [%lld]", _packet->transmit_timevalue.timevalue_secs, self.responseTimeNanos);
}


- (NSString *)description
{
    return ([NSString stringWithFormat:@"Message: version = [%u], msg_type = [%u], precision = [%u], reserved = [%u] max_freq_error = [%u] originate_timevalue_secs = [%u] originate_timevalue_nanos = [%u] receive_timevalue_secs = [%u] receive_timevalue_nanos = [%u] transmit_timevalue_secs = [%u] response_timevalue_nanos = [%lld]", _packet->version, _packet->message_type, _packet->precision, _packet->reserved, _packet->max_freq_error, _packet->originate_timevalue.timevalue_secs, _packet->originate_timevalue.timevalue_nanos, _packet->receive_timevalue.timevalue_secs, _packet->receive_timevalue.timevalue_nanos, _packet->transmit_timevalue.timevalue_secs, self.responseTimeNanos]);
}

void setCurrentTimeValueFromClock(WCTimeValue* tv, int64_t time)
{
    int64_t secs;
    int64_t nanos;
    uint32_t secs32;
    uint32_t nanos32;
    
    
    
    secs = time / kOneThousand_Million;
    
    nanos = time % kOneThousand_Million;
    
    secs32 = secs  & 0xffffffff;
    nanos32  = nanos & 0xffffffff;
    
    tv->timevalue_secs = htonl(secs32);
    tv->timevalue_nanos  = htonl(nanos32);
    
    //NSLog(@"hosttime=%lld secs=%u nanos=%u",time, secs32, nanos32);
}




void setCurrentTimeValue(WCTimeValue* tv)
{
    uint64_t secs;
    uint64_t nanos;
    uint32_t secs32;
    uint32_t nanos32;
    uint64_t hosttime;
    
    
    const uint64_t kOneThousandMillion = 1000000000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    hosttime = ((mach_absolute_time() * s_timebase_info.numer) /  s_timebase_info.denom);
    
    
    secs = hosttime / kOneThousandMillion;
    
    nanos = hosttime % kOneThousandMillion;
    
    secs32 = secs  & 0xffffffff;
    nanos32  = nanos & 0xffffffff;
    
    tv->timevalue_secs = htonl(secs32);
    tv->timevalue_nanos  = htonl(nanos32);
    
    //NSLog(@"hosttime=%llu secs=%u nanos=%u",hosttime, secs32, nanos32);
}



@end


