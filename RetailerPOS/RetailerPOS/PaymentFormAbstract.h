//
//  PaymentFormAbstract.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/28/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckoutViewController.h"
#import "Payment.h"

#import "MSForm.h"

@interface PaymentFormAbstract : UIViewController
@property (strong, nonatomic) CheckoutViewController *checkout;

@property (strong, nonatomic) Payment *method;

@property (strong, nonatomic) MSForm *form;

- (void)backToPaymentMethods;

- (void)updatePaymentData;

@end
