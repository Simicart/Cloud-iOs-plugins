//
//  StaffListViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/25/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StaffListViewController.h"
#import "MSFramework.h"
#import "User.h"
#import "StaffInfoViewController.h"

@implementation StaffListViewController
@synthesize userList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userList getSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserStaffListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    User *user = (User *)[userList objectAtIndex:[indexPath row]];
    
    NSString *name = @"";
    if (![MSValidator isEmptyString:[user objectForKey:@"first_name"]]) {
        name = [[user objectForKey:@"first_name"] stringByAppendingString:@" "];
    }
    if (![MSValidator isEmptyString:[user objectForKey:@"last_name"]]) {
        name = [name stringByAppendingString:[user objectForKey:@"last_name"]];
    }
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [user objectForKey:@"email"];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.userList objectAtIndex:[indexPath row]];
    
    StaffInfoViewController *infoView = [[StaffInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoView.listController = self;
    infoView.user = user;
    infoView.userList = userList;
    infoView.currentIndexPath = indexPath;
    [self.navigationController pushViewController:infoView animated:YES];
}

@end
