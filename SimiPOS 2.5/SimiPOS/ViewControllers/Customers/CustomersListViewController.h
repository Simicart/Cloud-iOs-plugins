//
//  CustomersListViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/27/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternetConnection.h"
#import "SVPullToRefresh.h"

#import "Customer.h"
#import "CustomerCollection.h"

@class CustomerInfoViewController;

@interface CustomersListViewController : UITableViewController <UISearchBarDelegate>
@property (strong, nonatomic) CustomerInfoViewController *editController;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) CustomerCollection *customerList;
@property (copy, nonatomic) NSString *searchTerm;

- (void)showSearchBar;
//- (void)searchKeyboardWillHide:(NSNotification *)note;
//- (void)enableCancelButton;
- (void)cancelSearch;

- (void)loadCustomer;
- (void)loadCustomerThread;

- (void)cleanData;

-(void)findCustomer:(Customer *)customer;

@end
