//
//  SettingSectionsViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "SettingSectionsViewController.h"
#import "ShowMenuButton.h"
#import "Account.h"

@interface SettingSectionsViewController ()

@end

@implementation SettingSectionsViewController
@synthesize settingForms, sections, currentSetting;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Table View Style
    self.tableView.rowHeight = 66;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.937 alpha:1];
    self.tableView.separatorColor = self.tableView.backgroundColor;
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.sections = @[
        @{@"title": NSLocalizedString(@"General", nil)},
        @{@"title": NSLocalizedString(@"My Account", nil), @"class": @"ProfileSettingsViewController"},
        //@{@"title": NSLocalizedString(@"Product", nil), @"class": @"StockSettingsViewController"},
        @{@"title": NSLocalizedString(@"Checkout", nil), @"class": @"CheckoutSettingsViewController"},
        @{@"title": NSLocalizedString(@"Print", nil), @"class": @"PrinterSettingsViewController"},
        //@{@"title": NSLocalizedString(@"Staff", nil), @"class": @"StaffSettingsViewController"},
        @{@"title": NSLocalizedString(@"Store Information", nil), @"class": @"StoreSettingsViewController"},
        @{@"title": NSLocalizedString(@"About", nil), @"class": @"AboutViewController"}
    ];
    
    // Navigation Button and Title
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[ShowMenuButton alloc] initMenuButton]];
    self.title = NSLocalizedString(@"Settings", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (![Account permissionValue:@"user.list"]) {
//        return [sections count] - 1;
//    }
    return [sections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingSectionsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
//        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    if (self.view.tag != 1) {
        NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:firstRow];
        [self.tableView selectRowAtIndexPath:firstRow animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.view.tag = 1;
    }
    
    NSDictionary *section = [sections objectAtIndex:[indexPath row]];
//    if ([indexPath row] > 4 && ![Account permissionValue:@"user.list"]) {
//        section = [sections objectAtIndex:[indexPath row] + 1];
//    }
    cell.textLabel.text = [section objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0) {
        if (self.currentSetting == nil) {
            [self.settingForms popToRootViewControllerAnimated:YES];
        } else {
            [self.settingForms popToRootViewControllerAnimated:NO];
            self.currentSetting = nil;
        }
        return;
    }
    NSDictionary *section = [sections objectAtIndex:[indexPath row]];
//    if ([indexPath row] > 4 && ![Account permissionValue:@"user.list"]) {
//        section = [sections objectAtIndex:[indexPath row] + 1];
//    }
    NSString *class = [section objectForKey:@"class"];
    if ([class isEqualToString:@""]) {
        return;
    }
    if ([class isEqualToString:[[self.currentSetting class] description]]) {
        [self.settingForms popToViewController:self.currentSetting animated:YES];
        return;
    }
    self.currentSetting = (UIViewController *)[(UITableViewController *)[NSClassFromString(class) alloc] initWithStyle:UITableViewStyleGrouped];
    [self.settingForms popToRootViewControllerAnimated:NO];
    [self.settingForms pushViewController:self.currentSetting animated:NO];
}

@end
