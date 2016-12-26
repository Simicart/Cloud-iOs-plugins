//
//  UIImage+SimiCustom.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/13/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SimiCustom)

- (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;

@end
