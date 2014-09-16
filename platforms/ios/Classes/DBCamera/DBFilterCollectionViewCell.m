//
//  DBFilterCollectionViewCell.m
//  HelloCordova
//
//  Created by Jose Luis Maroto on 21/07/14.
//
//

#import "DBFilterCollectionViewCell.h"
#import "DBCameraMacros.h"

@implementation DBFilterCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.contentView addSubview:self.itemImage];
        [self.contentView addSubview:self.itemLabel];
        [self.contentView addSubview:self.itemSelectedBar];
        if(self.selected){
            self.backgroundColor=RGBColor(0x041c27,1);
        }else{
            self.backgroundColor=RGBColor(0x03141d,1);
        }
    }
    return self;
}
- (UIImageView *) itemImage
{
    if( !_itemImage ) {
        _itemImage = [[UIImageView alloc] initWithFrame:(CGRect){ 10, 14, self.frame.size.width-20, self.frame.size.width-20 }];
        [_itemImage setBackgroundColor:[UIColor clearColor]];
        [_itemImage setContentMode:UIViewContentModeScaleAspectFill];
        [_itemImage setClipsToBounds:YES];
        _itemImage.layer.cornerRadius = 5.0;
        _itemImage.layer.borderColor=RGBColor(0x19aca8, 1).CGColor;
        if(self.selected){
            _itemImage.layer.borderWidth=0.0;
            [self setBackgroundColor:RGBColor(0x041c27, 1)];
        }else{
            _itemImage.layer.borderWidth=0.0;
            [self setBackgroundColor:[UIColor clearColor]];
        }
        _itemImage.layer.masksToBounds = YES;
    }
    
    return _itemImage;
}

- (UILabel *) itemLabel
{
    if(!_itemLabel){
        _itemLabel = [[UILabel alloc] initWithFrame:(CGRect){1,CGRectGetWidth([self bounds])+5,CGRectGetWidth([self bounds])-2,15}];
        [_itemLabel setBackgroundColor:[UIColor clearColor]];
        [_itemLabel setTintColor:[UIColor whiteColor]];
        [_itemLabel setAdjustsFontSizeToFitWidth:YES];
        _itemLabel.textColor=[UIColor whiteColor];
        _itemLabel.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
        _itemLabel.textAlignment= NSTextAlignmentCenter;
        
    }
    return _itemLabel;
}
- (UIView *)itemSelectedBar
{
    if(!_itemSelectedBar){
        _itemSelectedBar = [[UIView alloc] initWithFrame:(CGRect){1,1,CGRectGetWidth([self bounds])-2,4}];
        [_itemSelectedBar setBackgroundColor:[UIColor clearColor]];
        
        
    }
    return _itemSelectedBar;

}
@end
