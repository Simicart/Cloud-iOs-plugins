//
//  OrderSuccessViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/13/13.
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

@end
