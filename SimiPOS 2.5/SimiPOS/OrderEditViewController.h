//
//  OrderEditViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@class OrdersListViewController;

@interface OrderEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) OrdersListViewController *listViewController;
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
@property (strong, nonatomic) UIButton *invoiceBtn, *printBtn, *emailBtn, *refundBtn , *continueBtn ,*cancelBtn, *shipBtn;

- (void)invoiceOrder;
- (void)invoiceOrderThread;

- (void)cancelOrderThread;

- (void)printOrderForm;
- (void)showEmailForm;
- (void)showRefundForm;


#pragma mark - set type of viewcontroller
-(void)setTypeOfViewController:(BOOL)isHold;


@end
