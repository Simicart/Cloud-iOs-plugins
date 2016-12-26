//
//  HoldOrderEditViewController.h
//  SimiPOS
//
//  Created by mac on 2/22/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "PATransactionHandler.h"

@class HoldOrdersListViewController;

@interface HoldOrderEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, PATransactionHandlerDelegate>
@property (strong, nonatomic) HoldOrdersListViewController *listViewController;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) Order *order;
- (void)assignOrder:(Order *)order;

- (void)loadOrderDetailView;

// Load order info
- (void)loadOrder;
- (void)loadOrderThread;
- (void)reloadData;

// Order detail view
@property (strong, nonatomic) UITableView *tableView;

// Order actions
@property (strong, nonatomic) UIButton *invoiceBtn, *printBtn, *emailBtn, *refundBtn;

- (void)invoiceOrder;
- (void)invoiceOrderThread;

- (void)cancelOrderThread;

- (void)printOrderForm;
- (void)showEmailForm;
- (void)showRefundForm;


#pragma mark - set type of viewcontroller
-(void)setTypeOfViewController:(BOOL)isHold;
