//
//  MSClearButton.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSClearButton.h"

@implementation MSClearButton

+(id)buttonWithType:(UIButtonType)buttonType
{
    MSClearButton *btn = [super buttonWithType:buttonType];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_clear.png"] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[UIImage imageNamed:@"btn_clear_pressed.png"] forState:UIControlStateHighlighted];
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    return btn;
}

@end
