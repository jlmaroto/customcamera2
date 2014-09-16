//
//  DBCameraImageVIew.h
//  DBCamera
//
//  Created by iBo on 17/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBCameraImageViewDelegate;

@interface DBCameraImageView : UIImageView
@property (nonatomic, assign) CGPoint defaultCenter;
@property (nonatomic, assign, getter = isGesturesEnabled) BOOL gesturesEnabled;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat tx;
@property (nonatomic, assign) CGFloat ty;
@property (nonatomic, strong) UIImage* originalImage;

@property (nonatomic, weak) id<DBCameraImageViewDelegate> delegate;

- (void) resetPosition;
- (void) setFrame2:(CGRect)frame viewport:(CGRect)viewport;

@end

@protocol DBCameraImageViewDelegate <NSObject>

- (void)DBCameraImageView:(DBCameraImageView *)viewController
             didMove:(CGFloat)value;

- (void)DBCameraImageView:(DBCameraImageView *)viewController
                  didEndMove:(CGFloat)value;

@end