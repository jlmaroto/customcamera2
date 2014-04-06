//
//  DBCameraSegueView.m
//  DBCamera
//
//  Created by iBo on 17/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraSegueView.h"
#import "DBCameraImageView.h"
#import "DBCameraMacros.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

#define buttonMargin 20.0f
#define kCropStripeHeight (IS_RETINA_4 ? 154 : 110)

@interface StripeView : UIView
@end

@implementation StripeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:RGBColor(0x073b53, .6)];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, 1.0);
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, RGBColor(0xffffff, .7).CGColor);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect), 0);
    CGContextStrokePath(context);
}

@end


@interface DBCameraSegueView () {
    StripeView *_topStripe, *_bottomStripe;
    UIButton *_filterButtons[4];
}
@end

@implementation DBCameraSegueView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        UIView *transformView =[[UIView alloc] initWithFrame:self.bounds];
        
        _imageView = [[DBCameraImageView alloc] initWithFrame:(CGRect){ 0, 65, 320,320}];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_imageView setContentMode:UIViewContentModeScaleToFill];
        [transformView addSubview:_imageView];
        [self addSubview:transformView];
        
        _topStripe = [[StripeView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(frame), 65 }];
        [_topStripe.layer setAnchorPoint:(CGPoint){ .5, .5 }];
        [_topStripe setHidden:YES];
        [_topStripe setTransform:CGAffineTransformMakeRotation(M_PI)];
        [self addSubview:_topStripe];
        
        _bottomStripe = [[StripeView alloc] initWithFrame:(CGRect){ 0, 385, CGRectGetWidth(frame), CGRectGetHeight(frame)-385 }];
        [_bottomStripe setHidden:YES];
/*        for(int i=0;i<4;i++){
            [_bottomStripe addSubview:[self filterButton:i]];
            [_filterButtons[i] addTarget:self action:@selector(useFilterAction:) forControlEvents:UIControlEventTouchUpInside];
        }
*/
        [self addSubview:_bottomStripe];
        [self setCropMode:YES];
    }
    return self;
}

- (void) buildButtonInterface
{
    [self addSubview:self.stripeView];
    
    [self.retakeButton addTarget:self action:@selector(retakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retakeButton];
    
    [self.useButton addTarget:self action:@selector(useImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.useButton];
    
    //[self.cropButton addTarget:self action:@selector(cropQuad:) forControlEvents:UIControlEventTouchUpInside];
    //[self addSubview:self.cropButton];
    
    
}

- (UIView *) stripeView
{
    if ( !_stripeView ) {
        _stripeView = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 65 }];
        [_stripeView setBackgroundColor:RGBColor(0x073b53, .6)];
    }
    
    return _stripeView;
}

- (void) setCropMode:(BOOL)cropMode
{
    _cropMode = cropMode;
    [_topStripe setHidden:!_cropMode];
    [_bottomStripe setHidden:!_cropMode];
}

- (UIButton *) baseButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return button;
}

- (UIButton *) retakeButton
{
    if ( !_retakeButton ) {
        _retakeButton = [self baseButton];
        [_retakeButton setTitle:DBCameraLocalizedStrings(@"button.retake") forState:UIControlStateNormal];
        [_retakeButton.titleLabel sizeToFit];
        [_retakeButton sizeToFit];
        [_retakeButton setFrame:(CGRect){ 0, 0, CGRectGetWidth(_retakeButton.frame) + buttonMargin, 60 }];
    }
    
    return _retakeButton;
}

- (UIButton *) useButton
{
    if ( !_useButton ) {
        _useButton = [self baseButton];
        [_useButton setTitle:DBCameraLocalizedStrings(@"button.use") forState:UIControlStateNormal];
        [_useButton.titleLabel sizeToFit];
        [_useButton sizeToFit];
        [_useButton setFrame:(CGRect){ CGRectGetWidth(self.frame) - (CGRectGetWidth(_useButton.frame) + buttonMargin), 0, CGRectGetWidth(_useButton.frame) + buttonMargin, 60 }];
    }
    
    return _useButton;
}

- (UIButton *) cropButton
{
    if ( !_cropButton) {
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cropButton setBackgroundColor:[UIColor clearColor]];
        [_cropButton setImage:[UIImage imageNamed:@"CC2_Crop"] forState:UIControlStateNormal];
        [_cropButton setImage:[UIImage imageNamed:@"CC2_CropSelected"] forState:UIControlStateSelected];
        [_cropButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) - 15, 15, 30, 30 }];
    }
    
    return _cropButton;
}
-(UIButton *) filterButton:(int) i
{
    if(!_filterButtons[i]){
        _filterButtons[i] = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterButtons[i].tag=i;
        [_filterButtons[i] setBackgroundColor:RGBColor(0xffffff, .1)];
        [_filterButtons[i].layer setCornerRadius:4];
        [_filterButtons[i].layer setBorderWidth:1];
        [_filterButtons[i].layer setBorderColor:RGBColor(0xffffff, .3).CGColor];
        [_filterButtons[i] setFrame:(CGRect){  15+75*i, 50 - 32.5f, 65, 65 }];
        
    }
    return _filterButtons[i];
}
-(void) setFilter:(int)i
{
    if(_filterNumber>-1&&_filterNumber!=i){
        [_filterButtons[_filterNumber] setSelected:NO];
    }
    _filterNumber=i;
    
    if(i>-1){
        [_filterButtons[_filterNumber] setSelected:YES];
        if ( [_delegate respondsToSelector:@selector(useFilter:)] )
            [_delegate useFilter:i];
    }
    
}
#pragma mark - Methods

- (void) retakePhoto
{
    if ( [_delegate respondsToSelector:@selector(retakeImageFromCameraView:)] )
        [_delegate retakeImageFromCameraView:self];
}

- (void) useImage
{
    if ( [_delegate respondsToSelector:@selector(useImageFromCameraView:)] )
        [_delegate useImageFromCameraView:self];
}

- (void) cropQuad:(UIButton *)button
{
    [button setSelected:!button.isSelected];
    if ( [_delegate respondsToSelector:@selector(cameraView:cropQuadImageForState:)] )
        [_delegate cameraView:self cropQuadImageForState:button.isSelected];
}
- (void) useFilterAction:(UIButton *)button
{
    [self setFilter:button.tag];
}



@end
