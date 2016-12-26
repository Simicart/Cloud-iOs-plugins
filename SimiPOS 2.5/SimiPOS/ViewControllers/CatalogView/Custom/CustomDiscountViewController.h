//
//  CustomDiscountViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSFramework.h"

@interface CustomDiscountViewController : UIViewController <MSNumberPadDelegate, UITextFieldDelegate>
- (void)cancelEdit;

@property (strong, nonatomic) MSSegmentedControl *inputType;

@property (strong, nonatomic) UITextField *couponCode;
- (IBAction)toggleInputType:(id)sender;

@property (strong, nonatomic) UITextField *discountName;
@property (strong, nonatomic) MSSegmentedControl *discountType;
@property (strong, nonatomic) UITextField *discountPercentage;
@property (strong, nonatomic) UITextField *discountAmount;
@property (strong, nonatomic) UILabel *amountLabel;
@property (strong, nonatomic) MSNumberPad *keyboard;

- (IBAction)toggleDiscountType:(id)sender;

- (IBAction)addCustomDiscount:(id)sender;
- (void)addCustomDiscountThread;

@end
