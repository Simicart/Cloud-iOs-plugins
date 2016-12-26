//
//  CheckoutViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/19/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment.h"
#import "PaymentCollection.h"
#import "MSFramework.h"

@class ShippingViewController;

@interface CheckoutViewController : UIViewController <UITextFieldDelegate, MSNumberPadDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) ShippingViewController *shipping;

@property (strong, nonatomic) UIScrollView *paymentMethods;
@property (strong, nonatomic) UIControl *paymentMask;

@property (strong, nonatomic) UIControl *headerView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UILabel *headerTotal;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) MSNavigationController *methodNav;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIButton *cashButton, *orderButton;

- (void)reloadPaymentFormSize;
- (IBAction)hidePaymentMask;

@property (nonatomic) BOOL isCheckoutUpdate;
- (void)quoteUpdateComplete;

@property (strong, nonatomic) PaymentCollection *collection;

// Load data from server
- (void)reloadData;
- (void)loadPaymentDataThread;
- (void)updatePaymentMethods;

// Update buttons
- (void)reloadButtonStatus;

// Button Actions
- (void)placeOrderAction;
- (void)showSignatureForm;
- (void)showOrderSuccessForm;

- (void)placeOrderMain;

// Cash In Actions
@property (strong, nonatomic) UIView *cashInHeader;
@property (strong, nonatomic) UITextField *cashInValue;
@property (strong, nonatomic) UITextField *cashInRemain;
@property (strong, nonatomic) UIView *cashInView;
@property (strong, nonatomic) MSNumberPad *keyboard;

- (void)tapCashInButton;
- (long double)externalValue:(NSUInteger)tag;

@end
