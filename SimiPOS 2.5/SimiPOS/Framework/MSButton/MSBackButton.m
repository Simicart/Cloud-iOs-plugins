//
//  MSBackButton.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSBackButton.h"

@implementation MSBackButton

+(id)buttonWithType:(UIButtonType)buttonType
{
    MSBackButton *btn = [super buttonWithType:buttonType];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed.png"] forState:UIControlStateHighlighted];
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    return btn;
}

@end