//
//  StockSettingsViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 2/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StockSettingsViewController.h"
#import "MSFramework.h"
#import "Configuration.h"

@interface StockSettingsViewController ()
- (void)changeHideProductValue:(UISwitch *)sender;
- (void)changeHideOptionsValue:(UISwitch *)sender;
@end

@implementation StockSettingsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Product", nil);
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
    if ([indexPath section]) {
        cell.textLabel.text = NSLocalizedString(@"Hide Out-of-Stock Options", nil);
        [switcher addTarget:self action:@selector(changeHideOptionsValue:) forControlEvents:UIControlEventValueChanged];
        [switcher setOn:[[[Configuration globalConfig] objectForKey:@"in_stock_options"] boolValue]];
    } else {
        cell.textLabel.text = NSLocalizedString(@"Hide Out-of-Stock Products", nil);
        [switcher addTarget:self action:@selector(changeHideProductValue:) forControlEvents:UIControlEventValueChanged];
        [switcher setOn:[[[Configuration globalConfig] objectForKey:@"in_stock"] boolValue]];
    }
    cell.accessoryView = switcher;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section) {
        return NSLocalizedString(@"Product Options", nil);
    }
    return NSLocalizedString(@"Product List", nil);
}

#pragma mark - change config
- (void)changeHideProductValue:(UISwitch *)sender
{
    [[Configuration globalConfig] setValue:[NSNumber numberWithBool:[sender isOn]] forKey:@"in_stock"];
    BOOL needReloadProduct = ![[[Configuration globalConfig] objectForKey:@"reload_products"] boolValue];
    [[Configuration globalConfig] setValue:[NSNumber numberWithBool:needReloadProduct] forKey:@"reload_products"];
}

- (void)changeHideOptionsValue:(UISwitch *)sender
{
    [[Configuration globalConfig] setValue:[NSNumber numberWithBool:[sender isOn]] forKey:@"in_stock_options"];

}

@end
