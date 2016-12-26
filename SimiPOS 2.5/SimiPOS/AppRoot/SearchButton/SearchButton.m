//
//  SearchButton.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/22/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "SearchButton.h"

@implementation SearchButton

-(SearchButton *)initSearchButton
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 44, 44);
        
        [self setBackgroundImage:[UIImage imageNamed:@"search_icon.png"] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:@"search_icon_pressed.png"] forState:UIControlStateHighlighted];
    }
    return self;
}

@end
