//
//  ViewController.h
//  UDPClientDemo
//
//  Created by Rajiv Ramdhany on 03/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *addrField;

@property (weak, nonatomic) IBOutlet UITextField *portField;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

