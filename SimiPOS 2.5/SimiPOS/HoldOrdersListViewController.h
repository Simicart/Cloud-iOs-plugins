//
//  OrdersListViewController.h
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 22/2/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderEditViewController.h"
#import "SVPullToRefresh.h"

#import "Order.h"
#import "OrderCollection.h"

@interface HoldOrdersListViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) OrderEditViewController *editViewController;

@property (strong, nonatomic) OrderCollection *orderList;
@property (copy, nonatomic) NSString *searchTerm;

- (void)showSearchBar;
- (void)searchKeyboardWillHide:(NSNotification *)note;
- (void)enableCancelButton;
- (void)cancelSearch;

- (void)loadOrders;
- (void)loadOrdersThread;

- (void)cleanData;
- (void)reloadData;


@end
