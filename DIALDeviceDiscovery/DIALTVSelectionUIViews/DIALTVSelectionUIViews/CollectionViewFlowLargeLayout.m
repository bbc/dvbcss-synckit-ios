//
//  AFCollectionViewFlowLargeLayout.m
//  UICollectionViewFlowLayoutExample
//
//  Created by Rajiv Ramdhany on 12/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved

#import "CollectionViewFlowLargeLayout.h"

//------------------------------------------------------------------------------
#pragma mark - CollectionViewFlowSmallLayout implementation
//------------------------------------------------------------------------------

@implementation CollectionViewFlowLargeLayout

//------------------------------------------------------------------------------
#pragma mark - initialisers
//------------------------------------------------------------------------------

-(id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(130, 130);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.minimumInteritemSpacing = 10.0f;
    self.minimumLineSpacing = 10.0f;
    
    return self;
}
//------------------------------------------------------------------------------

@end
