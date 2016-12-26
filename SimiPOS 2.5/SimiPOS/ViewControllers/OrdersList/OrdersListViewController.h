//
//  OrdersListViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
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

@property (strong, nonatomic) NSMutableDictionary *orderRespone;
@property (strong, nonatomic) NSMutableArray *arrOrder;

- (void)showSearchBar;
- (void)searchKeyboardWillHide:(NSNotification *)note;
- (void)enableCancelButton;
- (void)cancelSearch;

- (void)loadOrders;
- (void)loadOrdersThread;

- (void)cleanData;
- (void)reloadData;

- (void)cleanCacheHoldOrder;

#pragma mark - set Title of ViewController
-(void)setTitleOfViewController:(NSString *)title;


@end
