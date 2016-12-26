//
//  CustomerListViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternetConnection.h"
#import "SVPullToRefresh.h"

#import "Customer.h"
#import "CustomerCollection.h"

@interface CustomerListViewController : UITableViewController <UIPopoverControllerDelegate, UISearchBarDelegate>
@property (strong, nonatomic) UIPopoverController *listPopover;
@property (strong, nonatomic) UITableView *itemTableView;

- (CGSize)reloadContentSize;

-(void)createCustomer;

@property (nonatomic) BOOL isShowedHeader;
@property (strong, nonatomic) UIView *headerBackground;
@property (strong, nonatomic) UIButton *createButton;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) CustomerCollection *customerList;
@property (copy, nonatomic) NSString *searchTerm;

-(void)loadCustomer;
-(void)loadCustomerSuccess;
-(void)loadCustomerError:(NSNotification *)note;

@end
