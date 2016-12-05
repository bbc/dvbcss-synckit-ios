//
//  utils.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 14/08/2014.
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

#import "utils.h"

long timevaldiff(struct timeval *starttime, struct timeval *finishtime)
{
    long long res;
    
    // Sanity check
    if (starttime && finishtime)
    {
        res = starttime->tv_sec;
        res = ((res - finishtime->tv_sec) * 1000000 + starttime->tv_usec - finishtime->tv_usec) / 1000;
        return (long) res;
    }
    return -1;
}



uint64_t getTimeInNanoseconds()
{
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return ((mach_absolute_time() * s_timebase_info.numer) / s_timebase_info.denom);
}



int64_t getUptimeInMilliseconds()
{
    const int64_t kOneMillion = 1000000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return (int64_t)((mach_absolute_time() * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom));
}

NSString * DisplayAddressForAddress(NSData * address)
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    char        servStr[NI_MAXSERV];
    
    
    result = nil;
    
    if (address != nil) {
        
        // If it's a IPv4 address embedded in an IPv6 address, just bring it as an IPv4
        // address.  Remember, this is about display, not functionality, and users don't
        // want to see mapped addresses.
        
        if ([address length] >= sizeof(struct sockaddr_in6)) {
            const struct sockaddr_in6 * addr6Ptr;
            
            addr6Ptr = [address bytes];
            if (addr6Ptr->sin6_family == AF_INET6) {
                if ( IN6_IS_ADDR_V4MAPPED(&addr6Ptr->sin6_addr) || IN6_IS_ADDR_V4COMPAT(&addr6Ptr->sin6_addr) ) {
                    struct sockaddr_in  addr4;
                    
                    memset(&addr4, 0, sizeof(addr4));
                    addr4.sin_len         = sizeof(addr4);
                    addr4.sin_family      = AF_INET;
                    addr4.sin_port        = addr6Ptr->sin6_port;
                    addr4.sin_addr.s_addr = addr6Ptr->sin6_addr.__u6_addr.__u6_addr32[3];
                    address = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
                    assert(address != nil);
                }
            }
        }
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), servStr, sizeof(servStr), NI_NUMERICHOST | NI_NUMERICSERV);
        if (err == 0) {
            result = [NSString stringWithFormat:@"%s:%s", hostStr, servStr];
            assert(result != nil);
        }
    }
    
    return result;
}


//NSString* WCSyncMessageToStringFromData(NSData *data)
//// Returns a human readable string for the given data.
//{
//    NSMutableString *   result;
//    NSUInteger          dataLength;
//    WCSyncMessagePkt*   _wcSynMsg;
//    assert(data != nil);
//    
//    dataLength = [data length];
//    _wcSynMsg = (WCSyncMessagePkt*) [data bytes];
//    
//    
//    result = [NSMutableString stringWithCapacity:dataLength];
//    assert(result != nil);
//    
//    [result appendString:@"\""];
//    
//    [result appendFormat:@"version:[%u], msg_type:[%u], precision:[%d], reserved:[%u] max_freq_error:[%u] ", _wcSynMsg->version, _wcSynMsg->message_type, (int8_t) _wcSynMsg->precision, _wcSynMsg->reserved, ntohl(_wcSynMsg->max_freq_error)];
//    
//    [result appendFormat:@"originate_tvsecs:[%u] originate_tvnanos:[%u] ", ntohl(_wcSynMsg->originate_timevalue.timevalue_secs), ntohl(_wcSynMsg->originate_timevalue.timevalue_nanos)];
//    [result appendFormat:@"receive_tvsecs:[%u] receive_tvnanos:[%u] ", ntohl(_wcSynMsg->receive_timevalue.timevalue_secs), ntohl(_wcSynMsg->receive_timevalue.timevalue_nanos)];
//    [result appendFormat:@"transmit_tvsecs:[%u] transmit_tvnanos:[%u] ", ntohl(_wcSynMsg->transmit_timevalue.timevalue_secs), ntohl(_wcSynMsg->transmit_timevalue.timevalue_nanos)];
//    
//    //    NSLog(@"Message: version = [%u], msg_type = [%u], precision = [%u], reserved = [%u] max_freq_error = [%u]", _wcSynMsg->version, _wcSynMsg->message_type, _wcSynMsg->precision, _wcSynMsg->reserved, ntohl(_wcSynMsg->max_freq_error));
//    //    NSLog(@"originate_timevalue_secs = [%u] originate_timevalue_nanos = [%u]", ntohl(_wcSynMsg->originate_timevalue.timevalue_secs), ntohl(_wcSynMsg->originate_timevalue.timevalue_nanos));
//    //    NSLog(@"receive_timevalue_secs = [%u] receive_timevalue_nanos = [%u]", ntohl(_wcSynMsg->receive_timevalue.timevalue_secs), ntohl(_wcSynMsg->receive_timevalue.timevalue_nanos));
//    //    NSLog(@"transmit_timevalue_secs = [%u] transmit_timevalue_nanos = [%u]", ntohl(_wcSynMsg->transmit_timevalue.timevalue_secs), ntohl(_wcSynMsg->transmit_timevalue.timevalue_nanos));
//    
//    return result;
//}

NSString * DisplayStringFromData(NSData *data)
// Returns a human readable string for the given data.
{
    NSMutableString *   result;
    NSUInteger          dataLength;
    NSUInteger          dataIndex;
    const uint8_t *     dataBytes;
    
    assert(data != nil);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    result = [NSMutableString stringWithCapacity:dataLength];
    assert(result != nil);
    
    [result appendString:@"\""];
    for (dataIndex = 0; dataIndex < dataLength; dataIndex++) {
        uint8_t     ch;
        
        ch = dataBytes[dataIndex];
        if (ch == 10) {
            [result appendString:@"\n"];
        } else if (ch == 13) {
            [result appendString:@"\r"];
        } else if (ch == '"') {
            [result appendString:@"\\\""];
        } else if (ch == '\\') {
            [result appendString:@"\\\\"];
        } else if ( (ch >= ' ') && (ch < 127) ) {
            [result appendFormat:@"%c", (int) ch];
        } else {
            [result appendFormat:@"\\x%02x", (unsigned int) ch];
        }
    }
    [result appendString:@"\""];
    
    return result;
}



NSString * DisplayHexStringFromData(NSData *data)
// Returns a human readable string for the given data.
{
    NSMutableString *   result;
    NSUInteger          dataLength;
    NSUInteger          dataIndex;
    const uint8_t *     dataBytes;
    
    assert(data != nil);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    result = [NSMutableString stringWithCapacity:dataLength];
    assert(result != nil);
    
    
    for (dataIndex = 0; dataIndex < dataLength; dataIndex++) {
        uint8_t     ch;
        
        ch = dataBytes[dataIndex];
        [result appendFormat:@"\\x%02x", (unsigned int) ch];
        
    }
    
    
    return result;
}

NSString * DisplayErrorFromError(NSError *error)
// Given an NSError, returns a short error string that we can print, handling
// some special cases along the way.
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    assert(error != nil);
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) ) {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = [NSString stringWithUTF8String:failureStr];
                    assert(result != nil);
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    assert(result != nil);
    return result;
}