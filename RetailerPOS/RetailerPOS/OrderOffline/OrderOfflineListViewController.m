//
//  OrderOfflineListViewController.m
//  RetailerPOS
//
//  Created by mac on 4/26/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OrderOfflineListViewController.h"

#import "OrderHistoryViewController.h"
#import "OrderDetailViewController.h"

@interface OrderOfflineListViewController ()

@end

@implementation OrderOfflineListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    OrderHistoryViewController * orderHistoryVC =[[OrderHistoryViewController alloc] initWithNibName:@"OrderHistoryViewController" bundle:nil];
    orderHistoryVC.view.frame =CGRectMake(0, 0, 400, WINDOW_HEIGHT);
    [orderHistoryVC didMoveToParentViewController:self];
    [self addChildViewController:orderHistoryVC];
    [self.view addSubview:orderHistoryVC.view];
    
    OrderDetailViewController * orderDetailVC =[[OrderDetailViewController alloc] initWithNibName:@"OrderDetailViewController" bundle:nil];
    orderDetailVC.view.frame = CGRectMake(400, 0, WINDOW_WIDTH -400, WINDOW_HEIGHT);
    [orderDetailVC didMoveToParentViewController:self];
    [self addChildViewController:orderDetailVC];
    [self.view addSubview:orderDetailVC.view];
    
    
    UIView * lineSeparateView =[[UIView alloc] init];
    lineSeparateView.backgroundColor =[UIColor groupTableViewBackgroundColor];
    lineSeparateView.frame =CGRectMake(400, 44, 1, WINDOW_HEIGHT);
    [self.view addSubview:lineSeparateView];
}


@end
