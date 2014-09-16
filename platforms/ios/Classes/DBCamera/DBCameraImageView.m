//
//  DBCameraImageVIew.m
//  DBCamera
//
//  Created by iBo on 17/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraImageView.h"
#import "DBCameraMacros.h"

#define SIZE_LIMIT 320

@interface DBCameraImageView () <UIGestureRecognizerDelegate> {
    
    CGFloat _lastRotation;
    
    CGFloat _lastScale;
    
	CGFloat _firstX;
	CGFloat _firstY;
    
    CGPoint corners[5];
    float minX;
    float minY;
    float maxX;
    float maxY;
    
    CGPoint translationDelta;
    
    CGPoint backVector;
    
    int activeGestures;
}

@end

@implementation DBCameraImageView
-(void) setImage:(UIImage*) newImage {
    [super setImage:newImage];
    _originalImage=[newImage copy];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        
        self.transform = CGAffineTransformIdentity;
        
        _tx = 0.0f;
        _ty = 0.0f;
        _scale = 1.0f;
        _lastScale = 1.0f;
        _rotation=0.0f;
        _lastRotation = 0.0f;
        
        activeGestures=0;
        
        
        corners[0]=CGPointMake(CGRectGetWidth(self.frame)/-2, CGRectGetHeight(self.frame)/-2);
        corners[1]=CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/-2);
        corners[2]=CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        corners[3]=CGPointMake(CGRectGetWidth(self.frame)/-2, CGRectGetHeight(self.frame)/2);
        corners[4]=corners[0];
        
        [self setGesturesEnabled:NO];
        
        // Add gesture recognizer suite
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        
        self.gestureRecognizers = @[  pinch, pan,rotate,press ];
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers)
            recognizer.delegate = self;
    }
    return self;
}

- (void) setFrame2:(CGRect)frame viewport:(CGRect)viewport
{
    [self setFrame:frame];
    corners[0]=CGPointMake(CGRectGetWidth(self.frame)/-2, CGRectGetHeight(self.frame)/-2);
    corners[1]=CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/-2);
    corners[2]=CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    corners[3]=CGPointMake(CGRectGetWidth(self.frame)/-2, CGRectGetHeight(self.frame)/2);
    corners[4]=corners[0];
    
    minX=CGRectGetMinX(viewport)-(CGRectGetMinX(self.frame)+(CGRectGetWidth(self.frame)/2));
    maxX=CGRectGetMaxX(viewport)-(CGRectGetMinX(self.frame)+(CGRectGetWidth(self.frame)/2));
    minY=CGRectGetMinY(viewport)-(CGRectGetMinY(self.frame)+(CGRectGetHeight(self.frame)/2));
    maxY=CGRectGetMaxY(viewport)-(CGRectGetMinY(self.frame)+(CGRectGetHeight(self.frame)/2));
    
}

- (void) resetPosition
{
    _tx = 0.0f;
    _ty = 0.0f;
    _scale = 1.0f;
    _rotation=0.0f;
    backVector.x=0;
    backVector.y=0;
    
    self.superview.transform= CGAffineTransformMakeTranslation(0, 0);
    self.transform = CGAffineTransformMakeTranslation(0, 0);
    self.transform = CGAffineTransformRotate(self.transform, 0);
    self.transform = CGAffineTransformScale(self.transform, 1, 1);
    [self countGestureBegin];
    [self countGestureEnd];
}
-(void) countGestureBegin{
    id<DBCameraImageViewDelegate> strongDelegate = self.delegate;
    
    activeGestures++;
    if (activeGestures==1&&[strongDelegate respondsToSelector:@selector(DBCameraImageView:didMove:)]) {
        [strongDelegate DBCameraImageView:self didMove:activeGestures];
    }
}
-(void) countGestureEnd{
    id<DBCameraImageViewDelegate> strongDelegate = self.delegate;
    
    activeGestures--;
    if (activeGestures==0&&[strongDelegate respondsToSelector:@selector(DBCameraImageView:didEndMove:)]) {
        [strongDelegate DBCameraImageView:self didEndMove:activeGestures];
    }
}
- (void) handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if ( !self.isGesturesEnabled )
        return;
    if(gesture.state==UIGestureRecognizerStateEnded){
        [self countGestureEnd];
    }else if(gesture.state==UIGestureRecognizerStateBegan){
        [self countGestureBegin];
    }
}


- (void) handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if ( !self.isGesturesEnabled )
        return;
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        [self countGestureBegin];
    }
    if( gesture.state == UIGestureRecognizerStateEnded ) {
		_lastScale = 1.0f;
//        if ( CGRectGetWidth(self.frame) < SIZE_LIMIT || CGRectGetHeight(self.frame) < SIZE_LIMIT )
//            [self resetPosition];
        [self countGestureEnd];
        
        return;
	}
    
	_scale = 1.0f - (_lastScale - [gesture scale]);
    
    
	CGAffineTransform currentTransform = self.transform;
	CGAffineTransform newTransform = CGAffineTransformScale( currentTransform, _scale, _scale );
    if([self checkConstraints:newTransform center:translationDelta]>0){
        return;
    }
    
	[self setTransform:newTransform];
    backVector.x=0;
    backVector.y=0;
	_lastScale = [gesture scale];
}

- (void) handlePan:(UIPanGestureRecognizer *)gesture
{
	if ( !self.isGesturesEnabled )
        return;

    UIView *piece = [gesture view];
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        [self countGestureBegin];
    }
    
    
    if ( gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged ) {
        CGPoint translation = [gesture translationInView:piece.superview];
        
        CGPoint checkTranslationDelta=CGPointMake(piece.superview.transform.tx+ translation.x, piece.superview.transform.ty + translation.y);
        if([self checkConstraints:self.transform center:checkTranslationDelta]>0){
            backVector.x+=translation.x;
            backVector.y+=translation.y;
            
        }else{
            backVector.x=0;
            backVector.y=0;
        }
        translationDelta=checkTranslationDelta;
        [piece.superview setTransform:CGAffineTransformTranslate(piece.superview.transform, translation.x, translation.y)];
//        [piece setCenter:(CGPoint){ piece.center.x + translation.x, piece.center.y + translation.y }];
        [gesture setTranslation:CGPointZero inView:piece.superview];
    }else if(gesture.state==UIGestureRecognizerStateEnded){
        if(backVector.x!=0||backVector.y!=0){
            [piece.superview setTransform:CGAffineTransformTranslate(piece.superview.transform, -backVector.x, -backVector.y)];
            backVector.x=0;
            backVector.y=0;
        }
        [self countGestureEnd];
    }
    
}
- (void) handleRotate:(UIRotationGestureRecognizer *)gesture
{
	if ( !self.isGesturesEnabled )
        return;
    
    if( gesture.state == UIGestureRecognizerStateEnded ) {
		_lastRotation = 0.0f;
        //        if ( CGRectGetWidth(self.frame) < SIZE_LIMIT || CGRectGetHeight(self.frame) < SIZE_LIMIT )
        //            [self resetPosition];
        [self countGestureEnd];
        
		return;
	}else if(gesture.state == UIGestureRecognizerStateBegan){
        [self countGestureBegin];
    }
    
	_rotation = 0.0f - (_lastRotation - [gesture rotation]);
    
    
    
	CGAffineTransform currentTransform = self.transform;
	CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, _rotation );
    if([self checkConstraints:newTransform center:translationDelta]>0){
        return;
    }
    _lastRotation = [gesture rotation];
    backVector.x=0;
    backVector.y=0;
    
	[self setTransform:newTransform];
}

- (BOOL)intersectsLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4
{
    CGFloat d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0)
        return false; // parallel lines
    CGFloat u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    CGFloat v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
    if (u < 0.0 || u > 1.0)
        return false; // intersection point not between p1 and p2
    if (v < 0.0 || v > 1.0)
        return false; // intersection point not between p3 and p4
    
    return true;
}

- (int) checkConstraints:(CGAffineTransform) transform center:(CGPoint)translation
{
    CGPoint tCorners[5];
    int frontierCode[5];
    for (int i=0; i<5; i++) {
        tCorners[i]=CGPointApplyAffineTransform(corners[i],transform);
        tCorners[i].x+=translation.x;
        tCorners[i].y+=translation.y;
        
        frontierCode[i]=0;
        if(tCorners[i].x<=minX){
            frontierCode[i]+=8;
        }else if(tCorners[i].x>=maxX){
            frontierCode[i]+=2;
        }
        if(tCorners[i].y<=minY){
            frontierCode[i]+=4;
        }else if(tCorners[i].y>=maxY){
            frontierCode[i]+=1;
        }
        if(frontierCode[i]==0){
            return pow(2,i+1)+1;
        }
    }
    //test if all frontier codes are in the same side
    int same=frontierCode[0];
    for(int i=1;i<5;i++){
        same=same&frontierCode[i];
    }
    if(same){
        return 1;
    }
    
    int result=0;
    for(int i=0;i<4;i++){
        if((frontierCode[i]&frontierCode[i+1])==0){
            if([self intersectsLineFrom:tCorners[i] to:tCorners[i+1] withLineFrom:CGPointMake(minX, minY) to:CGPointMake(maxX, minY)]){
                result+=pow(2,1+i*4);
            }
            if([self intersectsLineFrom:tCorners[i] to:tCorners[i+1] withLineFrom:CGPointMake(maxX, minY) to:CGPointMake(maxX, maxY)]){
                result+=pow(2,1+i*4+1);
            }
            
            if([self intersectsLineFrom:tCorners[i] to:tCorners[i+1] withLineFrom:CGPointMake(minX, maxY) to:CGPointMake(maxX, maxY)]){
                result+=pow(2,1+i*4+2);
            }
            
            if([self intersectsLineFrom:tCorners[i] to:tCorners[i+1] withLineFrom:CGPointMake(minX, minY) to:CGPointMake(minX, maxY)]){
                result+=pow(2,1+i*4+3);
            }
            
        }
    }
    
    
    
    
    return result;
}

- (void) adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = (CGPoint){ locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height };
        piece.center = locationInSuperview;
    }
}

#pragma mark - Gesture Delegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
	return YES;
}

#pragma mark - Touch Events

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[self.superview bringSubviewToFront:self];
    
	_tx = self.transform.tx;
	_ty = self.transform.ty;}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if ( touch.tapCount == 2 ){
		[self resetPosition];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
