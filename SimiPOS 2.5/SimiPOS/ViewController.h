//
//  ViewController.h
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 22/02/16.
//  Copyright (c) 2013 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuItem;
@class MarkLayerController;

@interface ViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *controllerClasses;
@property (strong, nonatomic) NSMutableArray *controllers;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic) MarkLayerController *markLayer;

@property (strong, nonatomic) NSMutableArray *menuItems;
@property (nonatomic) NSInteger currentMenuItem;

- (MenuItem *)addMenuItem:(NSString *)itemLabel withImage:(NSString *)imageOrNil controllerClass:(NSString *)controllerClass;

- (void)didSelectMenuItem: (MenuItem *)menuItem;

- (void)toggleViewMenu;

@property (nonatomic) BOOL activeMode;

@end
