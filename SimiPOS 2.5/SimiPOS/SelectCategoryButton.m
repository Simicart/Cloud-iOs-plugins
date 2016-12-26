//
//  SelectCategoryButton.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/22/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "SelectCategoryButton.h"

@implementation SelectCategoryButton

-(SelectCategoryButton *)initCategoryButton
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 5, 180, 30);
        
        [self setTitle:NSLocalizedString(@"All Products", nil) forState:UIControlStateNormal];
        
//        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [self setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:16]];
        
       // [self setBackgroundImage:[UIImage imageNamed:@"background_pressed.png"] forState:UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"dropdown_arrow.png"] forState:UIControlStateNormal];
        
        [self refreshButtonView];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth =1.0;
        self.layer.cornerRadius =2.0;
    }
    return self;
}

-(void)refreshButtonView
{
     //CGSize size = [[self titleForState:UIControlStateNormal] sizeWithFont:self.titleLabel.font];
      [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0,0,0 )];
    //[self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -70)];
     [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
}

@end
