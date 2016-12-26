//
//  OrdersListViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderEditViewController.h"
#import "SVPullToRefresh.h"

#import "Order.h"
#import "OrderCollection.h"

@interface OrdersListViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) OrderEditViewController *editViewController;

@property (strong, nonatomic) OrderCollection *orderList;
@property (copy, nonatomic) NSString *searchTerm;
@property (assign, nonatomic) BOOL isHoldOrder ;

- (void)showSearchBar;
- (void)searchKeyboardWillHide:(NSNotification *)note;
- (void)enableCancelButton;
- (void)cancelSearch;

- (void)loadOrders;
- (void)loadOrdersThread;

- (void)cleanData;
- (void)reloadData;

#pragma mark - set Title of ViewController
-(void)setTitleOfViewController:(NSString *)title;


@end
