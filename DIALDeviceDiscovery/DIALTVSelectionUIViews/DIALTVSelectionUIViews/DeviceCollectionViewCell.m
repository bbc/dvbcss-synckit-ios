//
//  AFCollectionViewCell.m
//  UICollectionViewFlowLayoutExample
//
//  Created by Rajiv Ramdhany on 12/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved

#import "DeviceCollectionViewCell.h"


//------------------------------------------------------------------------------
#pragma mark - DeviceCollectionViewCell (Interface Extension)
//------------------------------------------------------------------------------

@interface DeviceCollectionViewCell ()

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/** Cell Image view  */
@property (nonatomic, strong) UIImageView *imageView;

/** Cell Label */
@property (nonatomic, strong) UILabel *label;

//------------------------------------------------------------------------------

@end


//------------------------------------------------------------------------------
#pragma mark - DeviceCollectionViewCell implementation
//------------------------------------------------------------------------------
@implementation DeviceCollectionViewCell


//------------------------------------------------------------------------------
#pragma mark - Initialisers
//------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)), 5, 5)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.imageView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGRect imgFrame = self.imageView.frame;
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(imgFrame.origin.x, imgFrame.size.height, imgFrame.size.width , imgFrame.size.height * 0.2)];
            self.autoresizesSubviews = YES;
            self.label.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight);
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textColor = [UIColor colorWithRed:0.92 green:0.22 blue:0.44 alpha:1.0];
    self.label.textAlignment = NSTextAlignmentCenter;
    //        self.label.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:self.label];

    
    return self;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - Setters and other methods
//------------------------------------------------------------------------------

-(void)prepareForReuse
{
    [self setImage:nil];
}

//------------------------------------------------------------------------------

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

//------------------------------------------------------------------------------

-(void)setLabelText:(NSString*) text
{
    self.label.text = text;
}

//------------------------------------------------------------------------------

@end
