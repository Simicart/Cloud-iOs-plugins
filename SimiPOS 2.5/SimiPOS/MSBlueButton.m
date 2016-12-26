//
//  MSBlueButton.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/6/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSBlueButton.h"

@implementation MSBlueButton

+(id)buttonWithType:(UIButtonType)buttonType
{
    MSBlueButton *btn = [super buttonWithType:buttonType];
   
//    [btn setBackgroundImage:[[UIImage imageNamed:@"btn_blue_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[[UIImage imageNamed:@"btn_blue_bg_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted];
//    
    
    btn.backgroundColor =[UIColor barBackgroundColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    btn.layer.cornerRadius =5.0;
    
    
    return btn;
}

@end
