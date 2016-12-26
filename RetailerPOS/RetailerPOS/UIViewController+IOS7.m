//
//  UIViewController+IOS7.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/31/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "UIViewController+IOS7.h"
#import "Utilities.h"
#import <objc/runtime.h>

@implementation UIViewController (IOS7)

- (void)viewDidLoadIOS7
{
    [self viewDidLoadIOS7];
    if (![UIView areAnimationsEnabled]) {
        [UIView setAnimationsEnabled:YES];
    }
#if IOS7_SDK_AVAILABLE
    if ([Utilities iOSVersion7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
}

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewDidLoadIOS7)), class_getInstanceMethod(self, @selector(viewDidLoad)));
}

@end
