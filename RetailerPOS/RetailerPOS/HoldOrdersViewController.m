//
//  OrdersViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "HoldOrdersViewController.h"

#import "OrdersListViewController.h"
#import "MagentoOrderEditViewController.h"
#import "MSFramework.h"

@interface HoldOrdersViewController ()
@property (strong, nonatomic) OrdersListViewController *holdOrderList;
@property (strong, nonatomic) OrderEditViewController *orderView;
@end

@implementation HoldOrdersViewController
@synthesize holdOrderList, orderView;

static HoldOrdersViewController *_sharedInstance = nil;

+(HoldOrdersViewController*)sharedInstance
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
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
	// Do any additional setup after loading the view.
     self.view.frame = CGRectMake(0, 0, 1024, 768);
    //self.view.frame =CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    // Add Sub view
    holdOrderList = [[OrdersListViewController alloc] init];
    [holdOrderList setTitleOfViewController:@"Hold Order"];
    holdOrderList.isHoldOrder =YES;
    
    MSNavigationController *listNav = [[MSNavigationController alloc] initWithRootViewController:holdOrderList];
    listNav.view.frame = CGRectMake(0, 0, 427, WINDOW_HEIGHT);
    
    [self addChildViewController:listNav];
    [self.view addSubview:listNav.view];
    [listNav didMoveToParentViewController:self];
    
    orderView = [[MagentoOrderEditViewController alloc] init];
    [orderView setTypeOfViewController:YES];
    
    MSNavigationController *orderNav = [[MSNavigationController alloc] initWithRootViewController:orderView];
    orderNav.view.frame = CGRectMake(WINDOW_WIDTH -600, 0, 600, WINDOW_HEIGHT);
    
    [self addChildViewController:orderNav];
    [self.view addSubview:orderNav.view];
    [orderNav didMoveToParentViewController:self];
    
    holdOrderList.editViewController = orderView;
    orderView.listViewController = holdOrderList;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(holdOrderCancelSuccess) name:@"NotifyHoldOrderCancelSuccess" object:nil];
}

-(void)holdOrderCancelSuccess{
    
   // [Utilities toastSuccessTitle:@"Hold Order" withMessage:MESSAGE_CANCEL_SUCCESS withView:self.view];
    
    [holdOrderList cleanData];
    [orderView assignOrder:nil];

    [self performSelector:@selector(viewDidLoad) withObject:nil afterDelay:2.0];
    
   // [self viewDidLoad];
}

- (void)removeFromParentViewController
{
    // Free RAM
    [holdOrderList cleanData];
    [orderView assignOrder:nil];
    
    // Remove controller
    [super removeFromParentViewController];
}


@end