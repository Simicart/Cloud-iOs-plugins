//
//  ShowMenuButton.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/17/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ShowMenuButton.h"

@implementation ShowMenuButton

- (void)toggleViewMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"globalToggleViewMenu" object:self];
}

- (ShowMenuButton *)initMenuButton
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 44, 44);
        
        [self setBackgroundImage:[UIImage imageNamed:@"btn_show_menu.png"] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:@"btn_show_menu_pressed.png"] forState:UIControlStateHighlighted];
        
        //[self addTarget:self action:@selector(toggleViewMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(showLeftSideBarMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)showLeftSideBarMenu{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOW_LEFT_SIDE_BAR_MENU object:nil];
}

@end
