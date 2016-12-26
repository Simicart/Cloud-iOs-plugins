//
//  MSNoteButton.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 3/17/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSNoteButton.h"

@implementation MSNoteButton

+(id)buttonWithType:(UIButtonType)buttonType
{
    MSNoteButton *btn = [super buttonWithType:buttonType];
    [btn setBackgroundImage:[UIImage imageNamed:@"note_icon.png"] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[UIImage imageNamed:@"note_icon_pressed.png"] forState:UIControlStateHighlighted];
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    return btn;
}

@end
