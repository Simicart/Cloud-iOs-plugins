//
//  OrderSuccessViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2016/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSuccessViewController : UIViewController <UITextFieldDelegate>

- (void)changeEmailAddress;
- (void)doneEditEmailAddress;

- (void)sendEmailReceipt;
- (void)sendEmailReceiptThread;

- (void)printReceipt;

- (void)startNewOrder;

-(void)setGrandTotalPrice:(NSString *)totalPrice;

@end
