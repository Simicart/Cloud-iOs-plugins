//
//  UIImage+ImageColor.m
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "UIImage+ImageColor.h"

@implementation UIImage (ImageColor)

+(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect frame = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [color setFill];
    UIRectFill(frame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
