//
//  CustomSaleViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNumberPad.h"

@interface CustomSaleViewController : UIViewController <MSNumberPadDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *productName;
@property (strong, nonatomic) UITextField *productPrice;
@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UISwitch *productShipping;
@property (strong, nonatomic) UIButton *productAdd;

- (IBAction)addProductToCart:(id)sender;
- (void)addToCartThread;

@end
