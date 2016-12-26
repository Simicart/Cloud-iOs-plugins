//
//  StoreListViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/2/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StoreListViewController.h"
#import "Configuration.h"
#import "Account.h"
#import "MagentoAccount.h"

#import "LoginFormViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

#import "Stores.h"

@interface StoreListViewController ()
@property (strong, nonatomic) NSArray *storeUrls;

@property (strong, nonatomic) NSDictionary *storeInfo;
@end

@implementation StoreListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Store Name", nil);
    
     self.storeUrls = [Stores MR_findAll];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.storeUrls){
        return self.storeUrls.count;
        
    }else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreURLCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    Stores *store = [self.storeUrls objectAtIndex:indexPath.row];
    cell.textLabel.text = store.store_name;

    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = [UIImage imageNamed:@"icon_website_liv.png"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Choose Store", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"You will be automatically logged in again after changing store.", nil);
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Stores *store = [self.storeUrls objectAtIndex:indexPath.row];

        UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to change store?", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        [confirm showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        return;
    }
    
    //to do some thing
    
    
    // Logout to Old Store
    [(MagentoAccount *)[[Account currentAccount] getResource] logout];
    Configuration *config = [Configuration globalConfig];
    [config addEntriesFromDictionary:self.storeInfo];
    
    // Go to Login Form
    ViewController *viewController = (ViewController *)[(AppDelegate *)[[UIApplication sharedApplication] delegate] revealSideViewController];
    LoginFormViewController *loginForm = [LoginFormViewController new];
    [viewController addChildViewController:loginForm];
    [viewController.view addSubview:loginForm.view];
    [loginForm didMoveToParentViewController:viewController];

        loginForm.view.frame = CGRectMake(0, 0, 1024, 768);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountLogoutAfter" object:nil];
    // Back to Parent
    [self.navigationController popViewControllerAnimated:YES];
    
    [viewController.view bringSubviewToFront:loginForm.view];
}

@end
