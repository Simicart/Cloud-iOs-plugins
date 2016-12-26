//
//  MSClearButton.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/7/2016.
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
