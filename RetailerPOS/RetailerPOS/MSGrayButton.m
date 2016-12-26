//
//  MSGrayButton.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/6/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSGrayButton.h"

@implementation MSGrayButton

+(id)buttonWithType:(UIButtonType)buttonType
{
    MSGrayButton *btn = [super buttonWithType:buttonType];
    [btn setBackgroundImage:[[UIImage imageNamed:@"btn_gray_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [btn setBackgroundImage:[[UIImage imageNamed:@"btn_gray_bg_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted];
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    return btn;
}

@end
