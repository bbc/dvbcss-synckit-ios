//
//  WCSyncMessage.h
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

#import <Foundation/Foundation.h>
#import <UDPMessaging/UDPMessaging.h>
#import <ClockTimelines/ClockTimelines.h>


/*!
 * @typedef WCTimeValue
 * @brief TimeValue is seconds + nanosecs
 */
typedef struct __attribute__((packed)){
    
    uint32_t timevalue_secs;
    uint32_t timevalue_nanos;
    
}WCTimeValue;


/*!
 * @typedef WCSyncMessagePkt
 * @brief Wall Clock Synchronisation Message
 */
typedef struct __attribute__((packed)){
    uint8_t version;
    uint8_t message_type;
    uint8_t precision;
    uint8_t reserved;
    uint32_t max_freq_error;
    WCTimeValue originate_timevalue;
    WCTimeValue receive_timevalue;
    WCTimeValue transmit_timevalue;
}WCSyncMessagePkt;

#define WCSYNCMSG_SIZE sizeof(WCSyncMessagePkt)

/* CSS Wall Clock Synchronisation protocol message types */
#define WCMSG_REQ                   0
#define WCMSG_RESP                  1
#define WCMSG_RESP_WITH_FOLLOWUP    2
#define WCMSG_FOLLOWUP              3



/**
 A class that provides helper functions to build and parse Wall Clock protocol request/response
 messages
 */
@interface WCSyncMessage : NSObject

@property (nonatomic, readwrite) WCSyncMessagePkt *packet;
@property (nonatomic, readwrite) int64_t responseTimeNanos;

- (instancetype)init NS_UNAVAILABLE;

/**
 *   initialise with a buffer
 *
 *  @param buffer a buffer
 *
 *  @return initialised instance
 */
- (id)initWithBuffer:(uint8_t*) buffer;

/**
 *   Initialise with a packet and a response time (in nanos). Packet is deep-copied since only one
 buffer is used for receiving UDP packets.
 *
 *  @param packet        a WCSyncMessagePkt struct
 *  @param response_time response time
 *
 *  @return initialised instance
 */
- (id)initWithPacket:(WCSyncMessagePkt*) packet AndResponseTimeNanos:(int64_t) response_time;

/**
 *  set version of CSS-WC protocol
 *
 *  @param version -  protocol version
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setVersion:(uint8_t) version;

/**
 *  Set message type: see DVB CSS specs
 *
 *  @param msg_type     - a message type e.g. WCMSG_REQ, WCMSG_RESP, WCMSG_RESP_WITH_FOLLOWUP, WCMSG_FOLLOWUP
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setMessageType:(uint8_t) msg_type;

/**
 *  Set precision; value of this field only set for message type 1, 2 and 3. Value set as 2's complement integer
 *
 *  @param precision    - clock precision set as 2's complement integer
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setPrecision:(uint8_t) precision;

/**
 *  Set reserved field in WCSyncMessage
 *
 *  @param reserved     - value for reserved field
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setReserved:(uint8_t) reserved;


/**
 *  set max frequency error of Wall Clock
 *
 *  @param max_freq_error   - maximum frequency error of WallClock
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setMaxFreqError:(uint32_t) max_freq_error;

/**
 *  Set originate_timevalue field with given time value when a message type 0 is sent
 *
 *  @param timevalue_secs   - time value in seconds
 *  @param timevalue_nanos  - remaining time value in nanoseconds
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setOriginateTimeValueSeconds:(uint32_t) timevalue_secs AndNanoSecs:(uint32_t) timevalue_nanos;

/**
 *  Set originate_timevalue field with given time value when a message type 0 is sent
 *
 *  @param clockNanos   - time value in nanoseconds
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setOriginateTimeValue:(int64_t) clockNanos;

/**
 *  set receive_timevalue field with given time value when a message_type 0 is received
 *
 *  @param timevalue_secs  - time value in seconds
 *  @param timevalue_nanos - remaining time value in nanoseconds
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setReceiveTimeValueSeconds:(uint32_t) timevalue_secs AndNanoSecs:(uint32_t) timevalue_nanos;

/**
 *  set transmit_timevalue field  with given time value when message_type 1 is transmitted. Time value can be obtained from wallclock.
 *
 *  @param timevalue_secs  - time value in seconds
 *  @param timevalue_nanos - remaining time value in nanoseconds
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setTransmitTimeValueSeconds:(uint32_t) timevalue_secs AndNanoSecs:(uint32_t) timevalue_nanos;

/**
 *  Set  originate_timevaluefield with current host time (system clock) when a message type 0 is sent
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setOriginateTimeValueCurrentTime;

/**
 *  Set originate_timevalue field with time value of supplied clock when a message type 0 is sent
 *
 *  @param clock - a Clock instance (a subclassing ClockBase)
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setOriginateTimeValueCurrentTime:(ClockBase*) clock;

/**
 *  set receive_timevalue field with current host time (system clock) when message_type 0 is received
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setReceiveTimeValueCurrentTime;

/**
 *  set receive_timevalue field with supplied clock's time when message_type 0 is received
 *
 *  @param clock a clock object (subclassing ClockBase)
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setReceiveTimeValueCurrentTime:(ClockBase*) clock;

/**
 *  set transmitTime field with current host time (system clock) when message_type 1 is transmitted.
 *
 *  @return  WCSyncMessage instance with field set
 */
- (id) setTransmitTimeValueCurrentTime;

/**
 *  set transmitTime field with time value of supplied clock when message_type 1 is transmitted.
 *
 *  @param clock a clock object that subclasses ClockBase
 *
 *  @return WCSyncMessage instance with field set
 */
- (id) setTransmitTimeValueCurrentTime:(ClockBase*) clock;

- (NSString *)description;


/**
 *  get version field value
 *
 *  @return  version of CSS-WC protocol

 */
- (uint8_t) getVersion;;

/**
 *  message-type field value getter
 *
 *  @return message-type field value
 */
- (uint8_t) getMessageType;

/**
 *  precision field value getter
 *
 *  @return precision as a 2's complement integer
 */
- (uint8_t) getPrecision;

/**
 *  reserved field value getter
 *
 *  @return reserved field value
 */
- (uint8_t) getReserved;

/**
 *  MaxFreqError field value getter
 *
 *  @return MaxFreqError field value
 */
- (uint32_t) getMaxFreqError;

/**
 *  originate_timevalue field value getter
 *
 *  @return originate_timevalue field value
 */
- (WCTimeValue) getOriginateTimeValueSeconds;

/**
 *  originate_timevalue field value getter
 *
 *  @return originate_timevalue field value in nanoseconds
 */
- (int64_t) getOriginateTimeNanos;

/**
 *  receive_timevalue field value getter
 *
 *  @return receive_timevalue field value
 */
- (WCTimeValue) getReceiveTimeValueSeconds;

/**
 *  transmit_timevalue field value getter
 *
 *  @return transmit_timevalue field value
 */
- (WCTimeValue) getTransmitTimeValueSeconds;


@end



