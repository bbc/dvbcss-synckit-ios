//
//  ViewController.h
//  WallClockClientDemoApp
//
//  Created by Rajiv Ramdhany on 17/06/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *wcOffsetTextField;
@property (weak, nonatomic) IBOutlet UITextField *dispersionTextField;
@property (weak, nonatomic) IBOutlet UITextField *usefulTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *usefulCandPercentTextField;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
- (IBAction)StartWallClock:(id)sender;

@end

