//
//  OrderRefundViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "OrderRefundViewController.h"
#import "UIView+InputNotification.h"

#import "Price.h"
#import "MSTextField.h"
#import "Utilities.h"

@interface OrderRefundViewController ()
@property (nonatomic) BOOL isOnlineRefund;
@property (nonatomic) long double amountTotal, adjustment_positive, adjustment_negative;
@property (strong, nonatomic) UILabel *totalRefund;
@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UIPopoverController *popover;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
@end

@implementation OrderRefundViewController
@synthesize isOnlineRefund;
@synthesize amountTotal, adjustment_positive, adjustment_negative;
@synthesize totalRefund, keyboard, popover;
@synthesize animation;
@synthesize order = _order, editViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Navigation buttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelRefund)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.title = NSLocalizedString(@"Refund Amount", nil);
    
    UIBarButtonItem *offlineButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refund Offline", nil) style:UIBarButtonItemStyleDone target:self action:@selector(refundOffline)];
    
    NSString *paymentMethod = [self.order objectForKey:@"payment_method"];
    if ([paymentMethod isEqualToString:@"checkmo"]
        || [paymentMethod isEqualToString:@"cashondelivery"]
        || [paymentMethod isEqualToString:@"purchaseorder"]
        || ![[self.order objectForKey:@"can_refund_item"] boolValue]
    ) {
        self.navigationItem.rightBarButtonItem = offlineButton;
    } else {
        UIBarButtonItem *onlineButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refund", nil) style:UIBarButtonItemStyleDone target:self action:@selector(refundOnline)];
        self.navigationItem.rightBarButtonItems = @[onlineButton, offlineButton];
    }
    
    // Refund amount inputs
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 436, 66)];
    cell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cell];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 216, 26)];
    textLabel.font = [UIFont systemFontOfSize:20];
    textLabel.text = NSLocalizedString(@"Total", nil);
    [cell addSubview:textLabel];
    
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(226, 20, 200, 26)];
    amountLabel.font = [UIFont systemFontOfSize:24];
    amountLabel.textAlignment = NSTextAlignmentRight;
    amountTotal = [[self.order objectForKey:@"total_paid"] doubleValue] - [[self.order objectForKey:@"total_refunded"] doubleValue] - [[self.order objectForKey:@"total_canceled"] doubleValue];
    if ([[self.order objectForKey:@"can_refund_item"] boolValue]) {
        adjustment_positive = 0;
        adjustment_negative = 0;
    } else {
        adjustment_positive = amountTotal;
        adjustment_negative = 0;
        amountTotal = 0;
    }
    amountLabel.text = [Price format:[NSNumber numberWithDouble:amountTotal]];
    [cell addSubview:amountLabel];
    
    // Positive
    cell = [[UIView alloc] initWithFrame:CGRectMake(0, 66, 436, 66)];
    cell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cell];
    
    textLabel = [textLabel clone];
    textLabel.text = NSLocalizedString(@"Adjustment Refund", nil);
    [cell addSubview:textLabel];
    
    MSTextField *adjustment = [[MSTextField alloc] initWithFrame:CGRectMake(221, 13, 210, 40)];
    adjustment.font = [UIFont systemFontOfSize:22];
    adjustment.textAlignment = NSTextAlignmentRight;
    adjustment.text = [Price format:[NSNumber numberWithDouble:adjustment_positive]];
    adjustment.textPadding = UIEdgeInsetsMake(5, 5, 5, 5);
    adjustment.tag = 1;
    adjustment.delegate = self;
    adjustment.layer.borderColor = [UIColor colorWithWhite:0.97 alpha:1].CGColor;
    adjustment.layer.borderWidth = 1.0;
    [cell addSubview:adjustment];
    
    // Nagitive
    cell = [[UIView alloc] initWithFrame:CGRectMake(0, 132, 436, 66)];
    cell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cell];
    
    textLabel = [textLabel clone];
    textLabel.text = NSLocalizedString(@"Adjustment Fee", nil);
    [cell addSubview:textLabel];
    
    adjustment = [adjustment clone];
    adjustment.text = [Price format:[NSNumber numberWithDouble:adjustment_negative]];
    adjustment.textPadding = UIEdgeInsetsMake(5, 5, 5, 5);
    adjustment.tag = 2;
    adjustment.delegate = self;
    adjustment.layer.borderColor = [UIColor colorWithWhite:0.97 alpha:1].CGColor;
    adjustment.layer.borderWidth = 1.0;
    [cell addSubview:adjustment];
    
    // Refund Amount
    cell = [[UIView alloc] initWithFrame:CGRectMake(0, 199, 436, 66)];
    cell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cell];
    
    textLabel = [textLabel clone];
    textLabel.text = NSLocalizedString(@"Estimate Refund", nil);
    textLabel.textColor = [UIColor orangeColor];
    [cell addSubview:textLabel];
    
    totalRefund = [amountLabel clone];
    totalRefund.text = [Price format:[NSNumber numberWithDouble:(amountTotal + adjustment_positive - adjustment_negative)]];
    totalRefund.textColor = [UIColor orangeColor];
    [cell addSubview:totalRefund];
}

- (void)cancelRefund
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - edit adjusment
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (keyboard == nil) {
        keyboard = [MSNumberPad keyboard];
        [keyboard resetConfig];
        keyboard.delegate = self;
        keyboard.doneLabel = @"00";
        keyboard.floatPoints = [Price precision];
        keyboard.maxInput = 13;
        [keyboard showOn:self atFrame:CGRectMake(0, 0, 288, 241)];
        [keyboard willMoveToParentViewController:nil];
        [keyboard.view removeFromSuperview];
        [keyboard removeFromParentViewController];
    }
    keyboard.textField = textField;
    if (textField.tag == 1) {
        // Refund - adjustment_positive
        keyboard.currentValue = adjustment_positive;
    } else if (textField.tag == 2) {
        // Fee - adjustment_negative
        keyboard.currentValue = adjustment_negative;
    }
    
    if (popover == nil) {
        popover = [[UIPopoverController alloc] initWithContentViewController:keyboard];
        popover.popoverContentSize = CGSizeMake(288, 241);
    }
    [popover presentPopoverFromRect:textField.frame inView:textField.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    return NO;
}

- (void)numberPad:(MSNumberPad *)numberPad willShowButton:(UIButton *)button
{
    if (button.tag == 13) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    }
}

- (BOOL)numberPadShouldDone:(MSNumberPad *)numberPad
{
    UIButton *zeroButton = (UIButton *)[numberPad.view viewWithTag:0];
    [numberPad numberButtonTapped:zeroButton];
    [numberPad numberButtonTapped:zeroButton];
    return NO;
}

- (NSString *)numberPadFormatOutput:(MSNumberPad *)numberPad
{
    if (numberPad.textField.tag == 1) {
        adjustment_positive = numberPad.currentValue;
    } else {
        adjustment_negative = numberPad.currentValue;
    }
    totalRefund.text = [Price format:[NSNumber numberWithDouble:(amountTotal + adjustment_positive - adjustment_negative)]];
    return [Price format:[NSNumber numberWithDouble:numberPad.currentValue]];
}

#pragma mark - refund order methods
- (void)refundOffline
{
    isOnlineRefund = NO;
    [self confirmRefund];
}

- (void)refundOnline
{
    isOnlineRefund = YES;
    [self confirmRefund];
}

- (void)confirmRefund
{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to refund this order?", nil) delegate:self cancelButtonTitle:@"" destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [confirm showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self refundOrder];
    }
}

- (void)refundOrder
{
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = self.view.superview.bounds;
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.view.superview addSubview:animation];
    }
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(refundOrderThread) object:nil] start];
}

- (void)refundOrderThread
{
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Error when query
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderRefundSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self performSelectorOnMainThread:@selector(cancelRefund) withObject:nil waitUntilDone:NO];
        // Reload order data
        [self.editViewController loadOrder];
    }];
    
    NSNumber *doOffline = [NSNumber numberWithBool:!isOnlineRefund];
    NSNumber *positive = [NSNumber numberWithDouble:adjustment_positive];
    NSNumber *negative = [NSNumber numberWithDouble:adjustment_negative];
    [self.order creditmemo:@{
        @"do_offline": doOffline,
        @"adjustment_positive": positive,
        @"adjustment_negative": negative
    }];
    
    [animation stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

@end
