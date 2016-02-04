//
//  SCListPhoneViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/30/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCListPhoneViewController.h"

@interface SCListPhoneViewController ()

@end

@implementation SCListPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =SCLocalizedString(@"Select Phone");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneCell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_arrayPhone objectAtIndex:indexPath.row]];
    [cell.textLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _arrayPhone.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return SCLocalizedString(@"Select phone number");
}

#pragma mark TableView DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectPhoneNumber:[_arrayPhone objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
