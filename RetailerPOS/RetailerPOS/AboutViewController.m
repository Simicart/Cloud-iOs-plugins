//
//  AboutViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/2/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "AboutViewController.h"
#import "Configuration.h"
#import "MSFramework.h"
#import "Account.h"

@interface AboutViewController ()
- (void)buyRetailerPOS;
@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];

    self.title = NSLocalizedString(@"About", nil);
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    
    if ([indexPath section] == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 516, 30)];
        aboutLabel.font = [UIFont systemFontOfSize:16];
        aboutLabel.textAlignment = NSTextAlignmentCenter;
        aboutLabel.text = NSLocalizedString(@"MagetoPOS App for iPad", nil);
        [cell addSubview:aboutLabel];
        
        aboutLabel = [aboutLabel clone];
        aboutLabel.frame = CGRectMake(40, 60, 516, 30);
        aboutLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version %@", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [cell addSubview:aboutLabel];
        
        aboutLabel = [aboutLabel clone];
        aboutLabel.frame = CGRectMake(40, 100, 516, 30);
        aboutLabel.text = NSLocalizedString(@"© 2016 Magestore.com. All Rights Reserved.", nil);
        [cell addSubview:aboutLabel];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Go to MagetoPOS Website", nil);
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if (section) {
//        return NSLocalizedString(@"Website", nil);
//    }
    return NSLocalizedString(@"MagetoPOS", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
   
    //return NSLocalizedString(@"You are using the free version of RetailerPOS.\nPlease purchase the full version.", nil);
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

#pragma mark - buy now
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 101;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    MSBlueButton *buyBtn = (MSBlueButton *)[view viewWithTag:10];
    if (buyBtn == nil) {
        ((UITableViewHeaderFooterView *)view).textLabel.text = [((UITableViewHeaderFooterView *)view).textLabel.text stringByAppendingString:@"\n\n\n"];
        buyBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        buyBtn.frame = CGRectMake(208, 57, 180, 44);
        buyBtn.tag = 10;
        [view addSubview:buyBtn];
        [buyBtn setTitle:NSLocalizedString(@"Buy now", nil) forState:UIControlStateNormal];
        [buyBtn addTarget:self action:@selector(buyRetailerPOS) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)buyRetailerPOS
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[Configuration globalConfig] objectForKey:@"magestore_buy_url"]]];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[Configuration globalConfig] objectForKey:@"retailer_url"]]];
}

@end
