//
//  StoreUrlsViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginFormViewController.h"
#import "Account.h"

@interface StoreUrlsViewController : UITableViewController
@property (strong, nonatomic) LoginFormViewController *loginForm;
@property (strong, nonatomic) NSArray *storeList;

- (void)cancelSelect;

- (void)loginToStore;

@end
