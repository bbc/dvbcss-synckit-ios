//
//  DIALDeviceCollectionViewController.h
//  Acolyte
//
//  Created by Rajiv Ramdhany on 10/02/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIALDeviceViewConstants.h"
#import <DIALDeviceDiscovery/DIALDeviceDiscovery.h>


//------------------------------------------------------------------------------
#pragma mark - DIALDeviceCollectionViewController
//------------------------------------------------------------------------------
/**
 A ViewController which creates a UICollectionView and loads discovered DIAL devices from a DIALServiceDiscovery component.
 */
@interface DIALDeviceCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>


//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/** Devices collection view */
@property (strong, nonatomic) UICollectionView *devicesCollectionView;

/** UICollectionView's parent view */
@property (weak, nonatomic) UIView *parentView;

/** A reference to a DIALServiceDiscovery instance */
@property (weak, atomic)   DIALServiceDiscovery *tvDiscoveryComponent;

/** The view's title */
@property (strong, atomic, setter=setTitleString:) NSString *titleString;

/** A string identifier for a segue to trigger transition to next view on selecting a collection item */
@property (strong, nonatomic) NSString *segueIdentifier;

//------------------------------------------------------------------------------


@end
