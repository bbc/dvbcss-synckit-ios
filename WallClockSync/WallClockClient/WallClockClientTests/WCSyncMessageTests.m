//
//  WCSyncMessageTests.m
//  WallClockClient
//
//  Created by Rajiv Ramdhany on 11/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <SimpleLogger/SimpleLogger.h>
#import "WCSyncMessage.h"

@interface WCSyncMessageTests : XCTestCase

@end

@implementation WCSyncMessageTests
{
    uint8_t buffer[WCSYNCMSG_SIZE];
    
}
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMessageSerialisation {
    WCSyncMessage* wcmsg;
    
    wcmsg = [[WCSyncMessage alloc] initWithBuffer:buffer];
    
    [[[[[wcmsg setVersion:1] setMessageType:WCMSG_REQ] setPrecision:10] setReserved:5] setMaxFreqError:1000];
    
    // Originate (T1) timestamp
    [wcmsg setOriginateTimeValue:1234567891234564555];
     MWLogDebug(@"WCReq.originatetime=%lld", [wcmsg getOriginateTimeNanos]);
    
    XCTAssertEqual([wcmsg getVersion], 1, @"passed getter test");
    XCTAssertEqual([wcmsg getMessageType], WCMSG_REQ, @"passed getter test");
    XCTAssertEqual([wcmsg getPrecision], 10, @"passed getter test");
    XCTAssertEqual([wcmsg getReserved ], 5, @"passed getter test");
    XCTAssertEqual([wcmsg getMaxFreqError], 1000, @"passed getter test");
    XCTAssertEqual([wcmsg getOriginateTimeNanos], 1234567891234564555, @"passed getter test");
    

    
}


@end
