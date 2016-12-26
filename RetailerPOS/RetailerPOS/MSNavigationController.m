//
//  MSNavigationController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/4/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSNavigationController.h"
#import "Utilities.h"
#import "UIColor+SimiPOS.h"
#import "UIImage+ImageColor.h"

@implementation MSNavigationController

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#if IOS7_SDK_AVAILABLE
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor barBackgroundColor];
#else
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor barBackgroundColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor barBackgroundColor];
#endif
    
//    self.navigationBar.titleTextAttributes = @{UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]};

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

}

@end
