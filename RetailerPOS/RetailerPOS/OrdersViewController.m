//
//  OrdersViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "OrdersViewController.h"

#import "OrdersListViewController.h"
#import "MagentoOrderEditViewController.h"
#import "MSFramework.h"

@interface OrdersViewController ()
@property (strong, nonatomic) OrdersListViewController *orderList;
@property (strong, nonatomic) OrderEditViewController *orderView;
@end

@implementation OrdersViewController
@synthesize orderList, orderView;


static OrdersViewController *_sharedInstance = nil;

+(OrdersViewController*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sharedInstance=self;
    
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 1024, 768);
   // self.view.frame =CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    // Add Sub view
    orderList = [[OrdersListViewController alloc] init];
    MSNavigationController *listNav = [[MSNavigationController alloc] initWithRootViewController:orderList];
    listNav.view.frame = CGRectMake(0, 0, 427, WINDOW_HEIGHT);
    
    [self addChildViewController:listNav];
    [self.view addSubview:listNav.view];
    [listNav didMoveToParentViewController:self];
    
    orderView = [[MagentoOrderEditViewController alloc] init];
    MSNavigationController *orderNav = [[MSNavigationController alloc] initWithRootViewController:orderView];
    //orderNav.view.frame = CGRectMake(428, 0, 596, WINDOW_HEIGHT);
    orderNav.view.frame = CGRectMake(WINDOW_WIDTH -600, 0, 600, WINDOW_HEIGHT);
    
    [self addChildViewController:orderNav];
    [self.view addSubview:orderNav.view];
    [orderNav didMoveToParentViewController:self];
    
    orderList.editViewController = orderView;
    orderView.listViewController = orderList;
}

- (void)removeFromParentViewController
{
    // Free RAM
    [orderList cleanData];
    [orderView assignOrder:nil];
    
    // Remove controller
    [super removeFromParentViewController];
}


@end