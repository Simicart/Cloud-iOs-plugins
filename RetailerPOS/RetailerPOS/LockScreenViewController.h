//
//  LockScreenViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/2016/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSFramework.h"
#import "Configuration.h"

@interface LockScreenViewController : UIViewController <UITextFieldDelegate, MSNumberPadDelegate>

@property (strong, nonatomic) UIViewController * parrentVC;
@property (strong, nonatomic) MSTextField *pinText;
@property (strong, nonatomic) MSNumberPad *keyboard;

@end
