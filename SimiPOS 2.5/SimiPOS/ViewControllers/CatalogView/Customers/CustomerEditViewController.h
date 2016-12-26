//
//  CustomerEditViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quote.h"
#import "MSForm.h"

@interface CustomerEditViewController : UIViewController

@property (strong, nonatomic) Customer *customer;
@property (strong, nonatomic) MSForm *form;

- (void)cancelEdit;
- (void)saveCustomer;

// load customer data
- (void)loadCustomerData;

// process locale
- (void)reloadRegion;
- (void)changeCountry:(NSNotification *)note;

@end
