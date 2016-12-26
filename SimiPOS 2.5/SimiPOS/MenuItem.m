//
//  MenuItem.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/8/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MenuItem.h"
#import "ViewController.h"
#import "MSFramework.h"

@implementation MenuItem

@synthesize selectBackground;

@synthesize menuImageView;
@synthesize menuLabelView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 135, 125)];
    [view addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [view addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragExit];
    [view addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
    self.view = view;
    self.view.backgroundColor = [UIColor colorWithRed:0.176 green:0.224 blue:0.282 alpha:1.000];
    
    selectBackground = [[UIView alloc] initWithFrame:self.view.bounds];
    selectBackground.backgroundColor = [UIColor colorWithRed:0.145 green:0.183 blue:0.235 alpha:1.000];
    selectBackground.hidden = YES;
    [self.view addSubview:selectBackground];
    
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 16, 55, 55)];
    menuImageView.contentMode = UIViewContentModeBottom;
    [self.view addSubview:menuImageView];
    
   // menuLabelView = [[UILabel alloc] initWithFrame:CGRectMake(13, 76, 99, 21)];
    menuLabelView = [[UILabel alloc] initWithFrame:CGRectMake(13, 76, 99, 42)];
    menuLabelView.font = [UIFont systemFontOfSize:17];
    menuLabelView.textAlignment = NSTextAlignmentCenter;
    menuLabelView.textColor = [UIColor whiteColor];
    menuLabelView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    menuLabelView.minimumScaleFactor = 0.5;
    
    menuLabelView.numberOfLines=2;
    
    [self.view addSubview:menuLabelView];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 135, 1)];
    separator.backgroundColor = [UIColor colorWithRed:0.267 green:0.282 blue:0.345 alpha:1.000];
    [self.view addSubview:separator];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, 124, 135, 1)];
    separator.backgroundColor = [UIColor colorWithRed:0.141 green:0.157 blue:0.200 alpha:1.000];
    [self.view addSubview:separator];
}

- (void)clearStyle {
    self.selectBackground.hidden = YES;
    self.menuLabelView.textColor = [UIColor whiteColor];
    [self.menuImageView setHighlighted:NO];
}

- (void)selectStyle {
    self.selectBackground.hidden = NO;
    self.menuLabelView.textColor = [UIColor barBackgroundColor];
    [self.menuImageView setHighlighted:YES];
}

- (IBAction)touchDown:(id)sender {
    [self selectStyle];
}

- (IBAction)touchCancel:(id)sender {
    ViewController *parent = (ViewController *)self.parentViewController;
    if (parent.currentMenuItem != self.view.tag) {
        [self clearStyle];
    }
}

- (IBAction)selectItem:(id)sender {
    [self selectStyle];
    ViewController *parent = (ViewController *)self.parentViewController;
    [parent didSelectMenuItem:self];
}

@end
