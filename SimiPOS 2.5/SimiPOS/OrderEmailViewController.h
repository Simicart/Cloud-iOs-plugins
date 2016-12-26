//
//  OrderEmailViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@class MSTextField;

@interface OrderEmailViewController : UIViewController
@property (strong, nonatomic) Order *order;

- (void)cancelSendEmail;

@property (strong, nonatomic) MSTextField *emailAddress;
- (void)changeEmailAddress;
- (void)doneEditEmailAddress;

- (void)sendEmail;
- (void)sendEmailThread;

@end
