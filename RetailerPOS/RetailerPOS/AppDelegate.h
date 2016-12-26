//
//  AppDelegate.h
//  RetailerPOS
//
//  Edit by Nguyen Duc Chien on 7/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PPRevealSideViewControllerDelegate>

+(AppDelegate*)sharedInstance;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;

- (void)showLockScreenTimer;

@end
