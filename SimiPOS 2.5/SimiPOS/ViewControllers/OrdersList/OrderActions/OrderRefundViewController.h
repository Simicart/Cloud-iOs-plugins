//
//  OrderRefundViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "MSNumberPad.h"
#import "OrderEditViewController.h"

@class MSTextField;
@interface OrderRefundViewController : UIViewController <UITextFieldDelegate, MSNumberPadDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) OrderEditViewController *editViewController;
- (void)cancelRefund;

#pragma mark - refund
- (void)refundOffline;
- (void)refundOnline;

- (void)confirmRefund;
- (void)refundOrder;
- (void)refundOrderThread;

@end