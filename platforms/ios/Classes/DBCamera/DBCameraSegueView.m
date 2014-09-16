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
#import "DBCameraGridView.h"
#import "DBFilterCollectionViewCell.h"
#import "DBFilterCollectionViewFlowLayout.h"
#import "GPUImage.h"
#import "UIImage+Crop.h"


#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif
#define kItemIdentifier @"Filters"

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


@interface DBCameraSegueView () <UICollectionViewDataSource, UICollectionViewDelegate, DBCameraImageViewDelegate> {
    NSMutableArray *_items;
    UICollectionView *_collectionView;
    StripeView *_topStripe, *_bottomStripe;
}
@end

@implementation DBCameraSegueView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _items = [NSMutableArray array];
        
        [self setUserInteractionEnabled:YES];
        UIView *transformView =[[UIView alloc] initWithFrame:self.bounds];
        
        _imageView = [[DBCameraImageView alloc] initWithFrame:(CGRect){ 0, 65, 320,320}];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_imageView setContentMode:UIViewContentModeScaleToFill];
        [transformView addSubview:_imageView];
        [self addSubview:transformView];
        
        _filterView = [[DBEventlessView alloc] initWithFrame:(CGRect){ 0, 65, 320,320}];
        _imageView.delegate=self;
        [self addSubview:_filterView];
        _tempFilterView = [[DBEventlessView alloc] initWithFrame:(CGRect){ 0, 65, 320,320}];
        _tempFilterView.hidden=true;
        [self addSubview:_tempFilterView];
        
        _topStripe = [[StripeView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(frame), 65 }];
        [_topStripe.layer setAnchorPoint:(CGPoint){ .5, .5 }];
        [_topStripe setHidden:YES];
        [_topStripe setTransform:CGAffineTransformMakeRotation(M_PI)];
        [self addSubview:_topStripe];
        
        _bottomStripe = [[StripeView alloc] initWithFrame:(CGRect){ 0, 385, CGRectGetWidth(frame), CGRectGetHeight(frame)-385 }];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect){ 0, CGRectGetHeight(frame)-385 -114, CGRectGetWidth(frame), 114 } collectionViewLayout:[[DBFilterCollectionViewFlowLayout alloc] init]];
        
        
        [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBackgroundColor:RGBColor(0x042332, 1)];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView registerClass:[DBFilterCollectionViewCell class] forCellWithReuseIdentifier:kItemIdentifier];
        [_bottomStripe addSubview:_collectionView];
        //[_bottomStripe setHidden:YES];
/*        for(int i=0;i<4;i++){
            [_bottomStripe addSubview:[self filterButton:i]];
            [_filterButtons[i] addTarget:self action:@selector(useFilterAction:) forControlEvents:UIControlEventTouchUpInside];
        }
*/
        [self addSubview:_bottomStripe];
        
        [self setCropMode:YES];
        [self getFilters];

    }
    return self;
}
- (void) getFilters
{
    /*[_items addObjectsFromArray:@[@{@"image":@"wave_00.jpg",@"title":@"Normal",@"filter":@[]}
                                  ,@{@"image":@"wave_01.jpg",@"title":@"Mundaka",@"filter":@[]}
                                  ,@{@"image":@"wave_02.jpg",@"title":@"Oahu",@"filter":@[]}
                                  ,@{@"image":@"wave_03.jpg",@"title":@"Jeffrey's",@"filter":@[]}
                                  ,@{@"image":@"wave_04.jpg",@"title":@"Hossegor",@"filter":@[]}
                                  ,@{@"image":@"wave_05.jpg",@"title":@"Ulluwatu",@"filter":@[]}
                                  ,@{@"image":@"wave_06.jpg",@"title":@"Mundaka 1",@"filter":@[]}
                                  ,@{@"image":@"wave_07.jpg",@"title":@"Oahu 1",@"filter":@[]}
                                  ,@{@"image":@"wave_08.jpg",@"title":@"Jeffrey's 1",@"filter":@[]}
                                  ,@{@"image":@"wave_09.jpg",@"title":@"Hossegor 1",@"filter":@[]}
                                  ,@{@"image":@"wave_10.jpg",@"title":@"Ulluwatu 1",@"filter":@[]}
                                  ,@{@"image":@"wave_11.jpg",@"title":@"Mundaka 2",@"filter":@[]}
                                  ]];
    */
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    _items = [NSJSONSerialization JSONObjectWithData:data
                                             options:kNilOptions
                                               error:&error];
    
    
    [_collectionView reloadData];
    NSIndexPath *selection = [NSIndexPath indexPathForItem:0 inSection:0];
    [_collectionView selectItemAtIndexPath:selection animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    NSDictionary *filtro= _items[0];
    _filter=((NSArray *)[filtro objectForKey:@"filter"]);

    
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
        [_retakeButton setImage:[UIImage imageNamed:@"CC2_back"] forState:UIControlStateNormal];
        [_retakeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_retakeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_retakeButton setFrame:(CGRect){ buttonMargin, 15, 38 , 34 }];
    }
    
    return _retakeButton;
}

- (UIButton *) useButton
{
    if ( !_useButton ) {
        _useButton = [self baseButton];
        [_useButton setImage:[UIImage imageNamed:@"CC2_use"] forState:UIControlStateNormal];
        [_useButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_useButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_useButton setFrame:(CGRect){ CGRectGetWidth(self.frame) - 38 - buttonMargin, 15, 38 , 34 }];
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

-(void) DBCameraImageView:(DBCameraImageView *)viewController didEndMove:(CGFloat)value{
    _filterView.hidden = FALSE;
    _cropedImage=[[UIImage screenshotFromView:self] croppedImage:(CGRect){ 0, 130, 640, 640 }];
    
    [_filterView setFilteredImage:[self filterImage:_cropedImage]];
    
    [UIView animateWithDuration:0.20
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         _filterView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}
-(void) DBCameraImageView:(DBCameraImageView *)viewController didMove:(CGFloat)value{
    _filterView.alpha = 0.0;
    _filterView.hidden = true;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DBFilterCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:kItemIdentifier forIndexPath:indexPath];
    [item.itemImage setImage:nil];
    
    if ( _items.count > 0) {
        NSLog(@"%d %@ %@",indexPath.item,[_items[indexPath.item] objectForKey:@"image"],[_items[indexPath.item] objectForKey:@"title"]);
        [item.itemImage setImage:[UIImage imageNamed:[_items[indexPath.item] objectForKey:@"image"]]];
        [item.itemLabel setText:[_items[indexPath.item] objectForKey:@"title"]];
        if(item.selected){
            item.itemSelectedBar.backgroundColor=RGBColor(0x35d4ce, 1);
            item.backgroundColor=RGBColor(0x041c27, 1);
        }else{
            item.itemSelectedBar.backgroundColor=[UIColor clearColor];
            item.backgroundColor=RGBColor(0x03141d, 1);
        }
    }
    
    return item;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((DBFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).backgroundColor=RGBColor(0x041c27, 1);
    ((DBFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).itemSelectedBar.backgroundColor=RGBColor(0x35d4ce, 1);
    
    [(DBFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]setBackgroundColor:RGBColor(0x041c27, 1)];
    
    NSDictionary *filtro= _items[indexPath.item];
    _filter=((NSArray *)[filtro objectForKey:@"filter"]);
    
    UIImage *proxy=[self filterImage:_cropedImage];
    [_tempFilterView setImage:_filterView.filteredImage];
    _tempFilterView.alpha=1.0;
    _tempFilterView.hidden=false;
    _filterView.alpha=0.0;
    [_filterView setFilteredImage:proxy];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         _filterView.alpha = 1.0;
                         _tempFilterView.alpha=0.0;
                     }
                     completion:^(BOOL finished) {
                         _tempFilterView.hidden = true;
                         
                     }];
    
}
- (UIImage *) filterImage:(UIImage*)camaraImage{
    NSArray *filter=_filter;
    
    if(filter.count==0){
        [_filterView setFilteredImage:[_imageView.originalImage copy]];
        
    }else{
        
        NSMutableArray *results=[[NSMutableArray alloc] init];
        NSMutableArray *inputPictures=[[NSMutableArray alloc] init];
        for (NSDictionary *step in filter) {
            if ([[step objectForKey:@"type"] isEqual:@"input"]) {
                if ([[step objectForKey:@"from"] isEqual:@"camera"]) {
                    GPUImagePicture *input=[[GPUImagePicture alloc] initWithImage:camaraImage];
                    [inputPictures addObject:input];
                    
                    if([[step objectForKey:@"cropped"] isEqual:@"true"]){
                       // GPUImageCropFilter *crop=[[GPUImageCropFilter alloc] initWithCropRegion:<#(CGRect)#>];
                    }else{
                        [results setObject:input  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                    }
                }else if ([[step objectForKey:@"from"] isEqual:@"resource"]) {
                    GPUImagePicture *resource=[[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:[step objectForKey:@"name"]]] ;
                    [resource processImage];
                    [results setObject:resource atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                    [inputPictures addObject:resource];
                }else if ([[step objectForKey:@"from"] isEqual:@"color"]) {
                    GPUImageSolidColorGenerator* generator = [GPUImageSolidColorGenerator new];
                    [generator setColorRed:[[step objectForKey:@"red"] floatValue] green:[[step objectForKey:@"green"] floatValue] blue:[[step objectForKey:@"blue"] floatValue] alpha:[[step objectForKey:@"alpha"] floatValue]];
                    [generator forceProcessingAtSize:_imageView.originalImage.size];
                   
                    [results setObject:generator atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];

                }
            }else if([[step objectForKey:@"type"] isEqual:@"output"]){
                GPUImageFilter *f=[results objectAtIndex:[[step objectForKey:@"nodeId"] integerValue]];
                [f useNextFrameForImageCapture];
                for(id pic in inputPictures){
                    [pic processImage];
                }
//                return [f imageFromCurrentFramebufferWithOrientation:_imageView.originalImage.imageOrientation];
                return [f imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
            }else if([[step objectForKey:@"type"] isEqual:@"blend"]){
                if ([[step objectForKey:@"name"] isEqual:@"overlay"]) {
                    GPUImageOverlayBlendFilter *overlay = [[GPUImageOverlayBlendFilter alloc] init];
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:overlay];
                    }
                    [results setObject:overlay  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                }else if ([[step objectForKey:@"name"] isEqual:@"screen"]) {
                    GPUImageScreenBlendFilter *screen = [[GPUImageScreenBlendFilter alloc] init];
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:screen];
                    }
                    [results setObject:screen  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                }else if ([[step objectForKey:@"name"] isEqual:@"multiply"]) {
                    GPUImageMultiplyBlendFilter *multiply = [[GPUImageMultiplyBlendFilter alloc] init];
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:multiply];
                        
                    }
                    [results setObject:multiply  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                }else if ([[step objectForKey:@"name"] isEqual:@"lighten"]) {
                    GPUImageLightenBlendFilter *multiply = [[GPUImageLightenBlendFilter alloc] init];
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:multiply];
                        
                    }
                    [results setObject:multiply  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                }
            }else if([[step objectForKey:@"type"] isEqual:@"effect"]){
                if ([[step objectForKey:@"name"] isEqual:@"levels"]) {
                    GPUImageLevelsFilter *effect=[[GPUImageLevelsFilter alloc] init];
                    
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:effect];
                    }
                    [effect setMin:[[step objectForKey:@"dark" ] floatValue] gamma:[[step objectForKey:@"medium" ] floatValue] max:[[step objectForKey:@"light" ] floatValue]];
                    
                    [results setObject:effect  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                    
                }else if ([[step objectForKey:@"name"] isEqual:@"saturation"]) {
                    GPUImageSaturationFilter *effect=[[GPUImageSaturationFilter alloc] init];
                    
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:effect];
                    }
                    [effect setSaturation:[[step objectForKey:@"saturation" ] floatValue]];
                    
                    [results setObject:effect  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                    
                }else if ([[step objectForKey:@"name"] isEqual:@"hue"]) {
                    GPUImageHueFilter *effect=[[GPUImageHueFilter alloc] init];
                    
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:effect];
                    }
                    [effect setHue:[[step objectForKey:@"hue" ] floatValue]];
                    
                    [results setObject:effect  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                    
                }else if ([[step objectForKey:@"name"] isEqual:@"brightness"]) {
                    GPUImageBrightnessFilter *effect=[[GPUImageBrightnessFilter alloc] init];
                    
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:effect];
                    }
                    [effect setBrightness:[[step objectForKey:@"brightness" ] floatValue]];
                    
                    [results setObject:effect  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                }else if ([[step objectForKey:@"name"] isEqual:@"lookup"]) {
                    GPUImageLookupFilter *effect=[[GPUImageLookupFilter alloc] init];
                    
                    
                    NSArray *inputs=[step objectForKey:@"inputs"];
                    for(id i in inputs){
                        [[results objectAtIndex:[i intValue]] addTarget:effect];
                    }
                    
                    [results setObject:effect  atIndexedSubscript:[[step objectForKey:@"node"] integerValue]];
                    
                }
                
            }
        }
        
        
    }
    
}
- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((DBFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).backgroundColor=RGBColor(0x03141d,1);
    ((DBFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).itemSelectedBar.backgroundColor=[UIColor clearColor];
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


@end
