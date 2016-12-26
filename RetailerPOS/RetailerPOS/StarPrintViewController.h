//
//  StarPrintViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 7/18/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StarIOPrinterViewController.h"
#import "Order.h"

@interface StarPrintViewController : UIViewController <StarIOPrinterViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) UITableView *tableView;

- (void)cancelPrint;

#pragma mark - load order detail view
- (void)loadOrderDetailView;
- (void)loadOrderDetailThread;

#pragma mark - print order
- (void)printOrderAction;

@end
