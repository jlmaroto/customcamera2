//
//  DBEventlessView.m
//  HelloCordova
//
//  Created by Virginia García Sánchez on 11/09/14.
//
//

#import "DBEventlessView.h"

@implementation DBEventlessView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return NO;
}

-(void) setFilteredImage:(UIImage*) newImage {
    [super setImage:newImage];
    _filteredImage=newImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
