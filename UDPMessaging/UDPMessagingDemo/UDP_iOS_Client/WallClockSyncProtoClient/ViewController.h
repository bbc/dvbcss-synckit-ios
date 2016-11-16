//
//  ViewController.h
//  WallClockSyncProtoClient
//
//  Created by Rajiv Ramdhany on 24/07/2014.
//  Copyright (c) 2014 BBC R&D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController  <UDPCommsDelegate>

- (BOOL)runClientWithHost:(NSString *)host port:(NSUInteger)port;

@end
