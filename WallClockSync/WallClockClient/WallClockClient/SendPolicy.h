//
//  SendPolicy.h
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 01/10/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SyncKitCollections/SyncKitCollections.h>


/**
 *  A SendPolicy specifies a send policy used by the WCProtocolClient for scheduling the
 *  transmission of WC protocol request messages.
 */
@interface SendPolicy : Node

/** number of times to apply policy */
@property (nonatomic, readwrite) int count;

/** request wait time policy */
@property (nonatomic, readwrite) uint32_t waitTimeUSecs;

/**
 *  create a SendPolicy object
 *
 *  @param count_    - number of times to send a message
 *  @param wait_time - interval between messages
 *
 *  @return SendPolicy instance
 */
- (id) init: (int) count_ WaitTimeUSeconds: (uint32_t) wait_time;
@end
