
//  Created by Nguyen Duc Chien on 3/8/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.

#import "CustomersViewController.h"
#import "CustomersListViewController.h"
#import "CustomerInfoViewController.h"
#import "MSFramework.h"

@interface CustomersViewController ()
@property (strong, nonatomic) CustomersListViewController *customerList;
@property (strong, nonatomic) CustomerInfoViewController *customerEdit;
@end

@implementation CustomersViewController
@synthesize customerList, customerEdit;

static CustomersViewController *_sharedInstance = nil;

+(CustomersViewController*)sharedInstance
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
    
    _sharedInstance = self ;
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 1024, WINDOW_HEIGHT);
   // [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    // Add Sub View
    customerList = [CustomersListViewController new];
    MSNavigationController *listNav = [[MSNavigationController alloc] initWithRootViewController:customerList];
    listNav.view.frame =  CGRectMake(0, 0, 427, WINDOW_HEIGHT);
    
    [self addChildViewController:listNav];
    [self.view addSubview:listNav.view];
    [listNav didMoveToParentViewController:self];
    
    customerEdit = [CustomerInfoViewController new];
    MSNavigationController *editNav = [[MSNavigationController alloc] initWithRootViewController:customerEdit];
    editNav.view.frame = CGRectMake(WINDOW_WIDTH -600, 0, 600, WINDOW_HEIGHT);
    customerEdit.editNav =editNav;
    
    customerList.editController=customerEdit;
    customerEdit.listController=customerList;
    
    [self addChildViewController:editNav];
    [self.view addSubview:editNav.view];
    [editNav didMoveToParentViewController:self];
    
}

- (void)removeFromParentViewController
{
    // Free RAM
   // [customerList cleanData];
    // [customerEdit assignCustomer:nil];
    
    // Remove controller
  //  [super removeFromParentViewController];
}

@end
