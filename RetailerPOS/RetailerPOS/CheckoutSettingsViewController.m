//
//  CheckoutSettingsViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 5/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "CheckoutSettingsViewController.h"
#import "Configuration.h"

@interface CheckoutSettingsViewController ()

@end

@implementation CheckoutSettingsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Checkout", nil);
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
    
    [switcher setOnTintColor:[UIColor barBackgroundColor]];
    
    cell.accessoryView = switcher;
    if ([indexPath section]) {
        cell.textLabel.text = NSLocalizedString(@"Show Signature Form?", nil);
        [switcher addTarget:self action:@selector(changeSignatureSetting:) forControlEvents:UIControlEventValueChanged];
        [switcher setOn:[[[Configuration globalConfig] objectForKey:@"showsignform"] boolValue]];
    } else {
        cell.textLabel.text = NSLocalizedString(@"Create shipment when placing order", nil);
        [switcher addTarget:self action:@selector(changeDefaultShipment:) forControlEvents:UIControlEventValueChanged];
       
        [switcher setOn:BoolValue(KEY_CREATE_SHIPMENT)];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section) {
        return NSLocalizedString(@"Signature Form", nil);
    }
    return NSLocalizedString(@"Shipping", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section) {
        return NSLocalizedString(@"Show signature form after placed order by Credit Card", nil);
    }
    return nil;
}

#pragma mark - Change shipment
- (void)changeDefaultShipment:(id)sender
{
    //[[Configuration globalConfig] setValue:[NSNumber numberWithBool:[(UISwitch *)sender isOn]] forKey:@"createshipment"];
    SetBoolValue([(UISwitch *)sender isOn], KEY_CREATE_SHIPMENT);    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_CHANGE_VALUE_CREATE_SHIPMENT object:nil];
}

- (void)changeSignatureSetting:(id)sender
{
    [[Configuration globalConfig] setValue:[NSNumber numberWithBool:[(UISwitch *)sender isOn]] forKey:@"showsignform"];
}

@end
