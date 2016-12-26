
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
    self.view.frame = CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
   // [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    // Add Sub View
    customerList = [CustomersListViewController new];
    MSNavigationController *listNav = [[MSNavigationController alloc] initWithRootViewController:customerList];
    //Johan
    if(WINDOW_WIDTH >  1024){
        listNav.view.frame = CGRectMake(0, 0, WINDOW_WIDTH - 800, WINDOW_HEIGHT);
    }else{
        listNav.view.frame = CGRectMake(0, 0, WINDOW_WIDTH - 600, WINDOW_HEIGHT);
    }
    // End

    
    [self addChildViewController:listNav];
    [self.view addSubview:listNav.view];
    [listNav didMoveToParentViewController:self];
    
    customerEdit = [CustomerInfoViewController new];
    MSNavigationController *editNav = [[MSNavigationController alloc] initWithRootViewController:customerEdit];
    // Johan
    if(WINDOW_WIDTH >  1024){
        customerEdit.widthParent = 800;
        editNav.view.frame = CGRectMake(WINDOW_WIDTH -800, 0, 800, WINDOW_HEIGHT);
    }else{
        customerEdit.widthParent = 600;
        editNav.view.frame = CGRectMake(WINDOW_WIDTH -600, 0, 600, WINDOW_HEIGHT);
    }
    // End
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
