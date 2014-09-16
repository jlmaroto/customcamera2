//
//  DBFilterCollectionViewFlowLayout.m
//  HelloCordova
//
//  Created by Jose Luis Maroto on 21/07/14.
//
//

#import "DBFilterCollectionViewFlowLayout.h"

@implementation DBFilterCollectionViewFlowLayout
-(id) init
{
    self = [super init];
    if ( self ) {
        [self setItemSize:(CGSize){ 79, 110 }];
        [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [self setSectionInset:UIEdgeInsetsZero];
        [self setMinimumLineSpacing:1];
        [self setMinimumInteritemSpacing:2];
    }
    return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}
@end
