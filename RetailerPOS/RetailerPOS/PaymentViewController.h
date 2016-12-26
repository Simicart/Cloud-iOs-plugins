//
//  PaymentViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/28/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment.h"
//#import "PaymentCollection.h"
#import "CheckoutViewController.h"

@interface PaymentViewController : UITableViewController
@property (strong, nonatomic) CheckoutViewController *checkout;

//@property (strong, nonatomic) PaymentCollection *collection;
@property (strong, nonatomic) NSArray *collection;

@end
