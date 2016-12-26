//
//  CustomerInfoViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/27/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Customer.h"
#import "MSNavigationController.h"

@class CustomersListViewController;

@interface CustomerInfoViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) MSNavigationController *editNav;
@property (strong, nonatomic) CustomersListViewController *listController;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) Customer *customer;
- (void)assignCustomer:(Customer *)customer;

- (void)loadCustomerView;

- (void)addNewCustomer;
- (void)saveCustomer;
- (void)createOrder;

- (void)deleteCustomer;

@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UIButton *createOrderBtn;

// load customer data
- (void)loadCustomerData;

// process locale
- (void)reloadRegion;
- (void)changeCountry:(NSNotification *)note;
@end
