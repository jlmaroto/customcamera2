//
//  DBEventlessView.h
//  HelloCordova
//
//  Created by Virginia García Sánchez on 11/09/14.
//
//

#import <UIKit/UIKit.h>

@interface DBEventlessView : UIImageView

@property (nonatomic, strong) UIImage* filteredImage;

- (void) setFilteredImage:(UIImage*) newImage;

@end
