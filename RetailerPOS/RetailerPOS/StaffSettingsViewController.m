//
//  StaffSettingsViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/2/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StaffSettingsViewController.h"
#import "MSFramework.h"
#import "User.h"
#import "Account.h"
#import "StaffListViewController.h"
#import "StaffInfoViewController.h"
#import "LocationCollection.h"

@interface StaffSettingsViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (nonatomic) BOOL loadingData;

- (void)loadUsersThread;
- (void)reloadUserTable;
@end

@implementation StaffSettingsViewController
@synthesize userList, animation, loadingData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Staff Manager", nil);
    
    // Add user (Navigation Bar)
    if ([Account permissionValue:@"user.create"]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewStaffUser)];
    }
    
    self.userList = [UserCollection new];
    self.loadingData = NO;
    [self loadUsers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:NO];
    [super viewWillDisappear:animated];
}

#pragma mark - Load user from server
- (void)loadUsers
{
    if (self.loadingData || userList.loadCollectionFlag) {
        return;
    }
    self.loadingData = YES;
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = CGRectMake(0, 0, 596, 162);
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadUsersThread) object:nil] start];
}

- (void)loadUsersThread
{
    [userList load];
    self.loadingData = NO;
    [animation stopAnimating];
    if (userList.loadCollectionFlag) {
        [self performSelectorOnMainThread:@selector(reloadUserTable) withObject:nil waitUntilDone:NO];
        LocationCollection *collection = [LocationCollection allLocation];
        // [[collection clear] load]; // update changed - no need
        [collection load];
    }
}

- (void)reloadUserTable
{
    StaffListViewController *listControl = [[StaffListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    listControl.userList = userList;
    listControl.view.frame = self.view.bounds;
    [self addChildViewController:listControl];
    [self.view addSubview:listControl.view];
    [listControl didMoveToParentViewController:self];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Add new staff user
- (void)addNewStaffUser
{
    StaffInfoViewController *infoView = [[StaffInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    for (StaffListViewController *listControl in self.childViewControllers) {
        if ([listControl isKindOfClass:[StaffListViewController class]]) {
            infoView.listController = listControl;
        }
    }
    infoView.userList = self.userList;
    
    MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:infoView];
    navController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
