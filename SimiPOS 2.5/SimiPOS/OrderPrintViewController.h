//
//  OrderPrintViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/26/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface OrderPrintViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPrintInteractionControllerDelegate>
@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) UITableView *tableView;

- (void)cancelPrint;

#pragma mark - load order detail view
- (void)loadOrderDetailView;
- (void)loadOrderDetailThread;

#pragma mark - print order
- (void)printOrderAction;

@end
