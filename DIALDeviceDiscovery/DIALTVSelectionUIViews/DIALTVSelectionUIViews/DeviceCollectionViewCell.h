//
//  AFCollectionViewCell.h
//  UICollectionViewFlowLayoutExample
//
//  Created by Rajiv Ramdhany on 12/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved

#import <UIKit/UIKit.h>


//------------------------------------------------------------------------------
#pragma mark - DeviceCollectionViewCell
//------------------------------------------------------------------------------

/**
 A custom class for a UICollectionViewCell with an Image and a Label
 */
@interface DeviceCollectionViewCell : UICollectionViewCell


//------------------------------------------------------------------------------
#pragma mark - setters
//------------------------------------------------------------------------------

/**
 set cell's image
 */
-(void)setImage:(UIImage *)image;

//------------------------------------------------------------------------------

/**
 Set the cell's label text
 */
-(void)setLabelText:(NSString*) text;

//------------------------------------------------------------------------------

@end
