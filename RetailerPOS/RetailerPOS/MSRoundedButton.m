//
//  MSRoundedButton.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/3/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSRoundedButton.h"
#import "UIColor+SimiPOS.h"
#import "UIImage+ImageColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation MSRoundedButton

+ (id)buttonWithType:(UIButtonType)buttonType
{
    MSRoundedButton *btn = [super buttonWithType:buttonType];
    
//    // Background
//    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor buttonPressedColor]] forState:UIControlStateHighlighted];
    
    // Text
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
//    // Border
//    btn.layer.borderWidth = 0.5;
//    btn.layer.cornerRadius = 7.5;
//    btn.layer.masksToBounds = YES;
//    btn.layer.borderColor = [UIColor borderColor].CGColor;
    return btn;
}

@end
