//
//  AddCustomerViewController.h
//
//  Created by Nguyen Duc Chien
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNavigationController.h"

@class CustomerInfoViewController;
@interface AddCustomerViewController : UIViewController
@property (strong, nonatomic) CustomerInfoViewController *infoController;
@property (strong, nonatomic) MSNavigationController *editNav;

- (void)cancelAddCustomer;
- (void)dismissController:(NSNotification *)note;

- (void)saveCustomer;

@end
