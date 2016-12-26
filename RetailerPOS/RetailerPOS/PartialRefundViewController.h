//
//  PartialRefundViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 4/25/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "MSFramework.h"
#import "OrderEditViewController.h"

@interface PartialRefundViewController : UIViewController <UITextFieldDelegate, MSNumberPadDelegate, UIActionSheetDelegate, UITextViewDelegate>
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
