//
//  DBCameraUseViewController.m
//  DBCamera
//
//  Created by iBo on 11/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraSegueViewController.h"
#import "DBCameraMacros.h"
#import "DBCameraSegueView.h"
#import "UIImage+Crop.h"

@interface DBCameraSegueViewController () <DBCameraSegueViewDelegate> {
    DBCameraSegueView *_containerView;
}

@end

@implementation DBCameraSegueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    [self.view setUserInteractionEnabled:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _containerView = [[DBCameraSegueView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_containerView setBackgroundColor:RGBColor(0x202020, 1)];
    [_containerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_containerView setDelegate:self];
    [_containerView buildButtonInterface];
    [self cameraView:_containerView cropQuadImageForState:YES];
    [self.view addSubview:_containerView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_containerView.imageView setImage:self.capturedImage];
    
    if([_origin isEqual:@"LIBRARY"]){
        CGSize dimensions= self.capturedImage.size;
        CGFloat newWidth=320.0;
        CGFloat newHeight=320.0;
        CGFloat newX=0.0;
        CGFloat newY=0.0;
        CGRect usedViewport=CGRectMake(0, 65, 320, 320);
        if(dimensions.height>dimensions.width){
            newWidth=usedViewport.size.width;
            newHeight=dimensions.height*newWidth/dimensions.width;
        }else{
            newHeight=usedViewport.size.height;
            newWidth=dimensions.width*newHeight/dimensions.height;
        }
        
        newX=usedViewport.size.width/2-newWidth/2+usedViewport.origin.x;
        newY=usedViewport.size.height/2-newHeight/2+usedViewport.origin.y;
        [_containerView.imageView setFrame2:(CGRect){ newX,newY,newWidth,newHeight} viewport:usedViewport];
        [_containerView.imageView setDefaultCenter:_containerView.imageView.center];
    }else{
        CGFloat newWidth = [self getNewWidth];
        CGFloat newX = ((CGRectGetWidth([[UIScreen mainScreen] bounds])) * .5) - (newWidth * .5);
        [_containerView.imageView setFrame2:(CGRect){ newX,0,newWidth,
            CGRectGetHeight(_containerView.frame) } viewport:CGRectMake(0, 65, 320, 320)];
        [_containerView.imageView setDefaultCenter:_containerView.imageView.center];
    }
    _containerView.cropedImage=[[UIImage screenshotFromView:_containerView] croppedImage:(CGRect){ 0, 130, 640, 640 }];
}

- (CGFloat) getNewHeight
{
    return ( CGRectGetWidth([[UIScreen mainScreen] bounds]) * self.capturedImage.size.height ) / self.capturedImage.size.width;
}
- (CGFloat) getNewWidth
{
    return ( CGRectGetHeight([[UIScreen mainScreen] bounds]) * self.capturedImage.size.width ) / self.capturedImage.size.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) setCapturedImage:(UIImage *)capturedImage
{
    _capturedImage = capturedImage;
}

- (void) setOrigin:(NSString *)origin
{
    _origin=origin;
}

#pragma mark - DBCameraViewDelegate

- (void) retakeImageFromCameraView:(DBCameraSegueView *)cameraView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) useImageFromCameraView:(DBCameraSegueView *)cameraView
{
    if ( [cameraView isCropModeOn] ) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        NSNumber *orientation= [NSNumber numberWithInt: UIImageOrientationUp] ;
        [newDict addEntriesFromDictionary: self.capturedImageMetadata];
        [newDict setObject:orientation forKey:@"Orientation"];
        if ( [_delegate respondsToSelector:@selector(captureImageDidFinish:withMetadata:)] ){
            
            if(cameraView.filterView.filteredImage!=nil){
            [_delegate captureImageDidFinish:cameraView.filterView.filteredImage withMetadata:newDict];
            }else{
                [_delegate captureImageDidFinish:[[UIImage screenshotFromView:self.view] croppedImage:(CGRect){ 0, 130, 640, 640 }] withMetadata:newDict];
            }
        }
    } else if ( [_delegate respondsToSelector:@selector(captureImageDidFinish:withMetadata:)] )
        [_delegate captureImageDidFinish:self.capturedImage withMetadata:self.capturedImageMetadata];
}

- (void) cameraView:(DBCameraSegueView *)cameraView cropQuadImageForState:(BOOL)state
{
    [cameraView setCropMode:state];
    [cameraView.imageView setGesturesEnabled:state];
    if ( state == NO )
        [cameraView.imageView resetPosition];
}

@end
