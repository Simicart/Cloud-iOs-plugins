//
//  StoreSettingsViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/2/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StoreSettingsViewController.h"
#import "Configuration.h"
#import "Store.h"
#import "UIImageView+WebCache.h"

#import "StoreListViewController.h"
#import "MSFramework.h"

#import "UrlDomainConfig.h"

@interface StoreSettingsViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (BOOL)isStoreLoaded;
- (void)loadStoreInfo;
- (void)loadStoreInfoThread;
- (void)buyRetailerPOS;
@end

@implementation StoreSettingsViewController{
    UrlDomainConfig * urlConfigItems;
}
@synthesize animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Store Information", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    animation.frame = CGRectMake(200, 10, 20, 20);
   // animation.center =self.tableView.center;
    
    urlConfigItems =[[UrlDomainConfig MR_findAll] firstObject];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
    [super viewWillAppear:animated];
    [self loadStoreInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:NO];
    [super viewWillDisappear:animated];
}

#pragma mark - Load store information
- (BOOL)isStoreLoaded
{
    return [[Store currentStore] isLoaded];
}

- (void)loadStoreInfo
{
    if ([self isStoreLoaded]) {
        return;
    }
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadStoreInfoThread) object:nil] start];
}

- (void)loadStoreInfoThread
{
    Store *store = [Store currentStore];
    if (![store isLoaded]) {
        [store load:nil];
        [self.tableView reloadData];
    }
    [animation stopAnimating];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        
        UIImageView *storeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(45, 10, 506, 54)];
        storeLogo.contentMode = UIViewContentModeCenter;
        storeLogo.tag = 1;
        [cell addSubview:storeLogo];
        
        UILabel *storeAddress = [[UILabel alloc] initWithFrame:CGRectMake(45, 68, 506, 44)];
        storeAddress.numberOfLines = 0;
        storeAddress.font = [UIFont systemFontOfSize:18];
        storeAddress.tag = 2;
        storeAddress.textAlignment = NSTextAlignmentCenter;
        storeAddress.text = @"";
        [cell addSubview:storeAddress];
    }
    
    [cell viewWithTag:1].hidden = YES;
    [cell viewWithTag:2].hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    if ([indexPath section] == 1) {
        // Store Information
        cell.textLabel.text = nil;
        if ([self isStoreLoaded]) {
            Store *store = [Store currentStore];
            [cell viewWithTag:1].hidden = NO;
            [((UIImageView *)[cell viewWithTag:1]) setImageWithURL:[NSURL URLWithString:[store objectForKey:@"print_logo"]]];
            
            UILabel *storeAddress = (UILabel *)[cell viewWithTag:2];
            storeAddress.hidden = NO;
            NSArray *addresses = [self storeAddress];
            storeAddress.text = [addresses componentsJoinedByString:@"\n"];
            storeAddress.frame = CGRectMake(45, 68, 506, [addresses count] * 22 + 22);
        }
        return cell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if ([indexPath section] == 0) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        //Store URL Live
        if(indexPath.row == 0){
            cell.textLabel.text = urlConfigItems.domain_live;
            cell.imageView.image = [UIImage imageNamed:@"icon_website_liv.png"];
            
            //Store URL Develop
        }else{
            cell.textLabel.text = urlConfigItems.domain_dev;
            cell.imageView.image = [UIImage imageNamed:@"icon_website_dev.png"];
        }
        
        //Truong hop demo khong hien thi url

        if(BoolValue(KEY_CHECK_USE_TRY_DEMO)){
             cell.textLabel.text =@"Demo store's URL";
        }
                
        
    }else if(indexPath.section == 2){
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        NSString * tillName=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_STORE_NAME];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",tillName];
        cell.imageView.image = [UIImage imageNamed:@"small_business2"];
        
    }
    else if(indexPath.section == 3){
     
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        NSString * tillName=[[NSUserDefaults standardUserDefaults] objectForKey:KEY_TILL_NAME];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",tillName];
        cell.imageView.image = [UIImage imageNamed:@"cash_register2"];
        
    }else {
        
        cell.textLabel.text = NSLocalizedString(@"Go to MagetoPOS Website", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Store URL", nil);
    } else if (section == 1) {
        if ([self isStoreLoaded]) {
            return NSLocalizedString(@"Store Information", nil);
        }
        return NSLocalizedString(@"    Loading...", nil);
    } else if (section == 2){
        return @"Store Name";
    }
    else if (section == 3){
        return @"Cash Drawer Name";
    }
    
    return NSLocalizedString(@"MagetoPOS Website", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section != 1) {
        return nil;
    }
    
   // return NSLocalizedString(@"You are using the free version of MegetoPOS.Please purchase the full version.", nil);
    
    return nil;
}

#pragma mark - buy now
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (section == 1) {
//        return 101;
//    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
//    MSBlueButton *buyBtn = (MSBlueButton *)[view viewWithTag:10];
//    if (buyBtn == nil) {
//        ((UITableViewHeaderFooterView *)view).textLabel.text = [((UITableViewHeaderFooterView *)view).textLabel.text stringByAppendingString:@"\n\n\n"];
//        buyBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
//        //buyBtn.frame = CGRectMake(208, 57, 180, 44);
//        buyBtn.frame = CGRectMake(208, 100, 180, 44);
//        buyBtn.tag = 10;
//        [view addSubview:buyBtn];
//        [buyBtn setTitle:NSLocalizedString(@"Buy now", nil) forState:UIControlStateNormal];
//        [buyBtn addTarget:self action:@selector(buyRetailerPOS) forControlEvents:UIControlEventTouchUpInside];
//    }
}

- (void)buyRetailerPOS
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[Configuration globalConfig] objectForKey:@"magestore_buy_url"]]];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (section != 1) {
        return;
    }
    if ([self isStoreLoaded]) {
        [animation stopAnimating];
        [animation removeFromSuperview];
    } else {
        [view addSubview:animation];
        [animation startAnimating];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1 && [self isStoreLoaded]) {
        return [[self storeAddress] count] * 22 + 96;
    }
    return 54;
}

- (NSArray *)storeAddress
{
    Store *store = [Store currentStore];
    NSMutableArray *addresses = [NSMutableArray new];
    [addresses addObject:[store objectForKey:@"name"]];
    if ([[store objectForKey:@"address"] isKindOfClass:[NSString class]]) {
        [addresses addObjectsFromArray:[[store objectForKey:@"address"] componentsSeparatedByString:@"\n"]];
    }
    if ([store objectForKey:@"phone"]
        && [[store objectForKey:@"phone"] isKindOfClass:[NSString class]]
        && ![[store objectForKey:@"phone"] isEqualToString:@""]
        ) {
        [addresses addObject:[NSLocalizedString(@"Tel  ", nil) stringByAppendingString:[store objectForKey:@"phone"]]];
    }
    return addresses;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([indexPath section] == 0) {
//        //  StoreListViewController *storeList = [[StoreListViewController alloc] initWithStyle:UITableViewStyleGrouped];
//        // [self.navigationController pushViewController:storeList animated:YES];
//    } else if ([indexPath section] == 2) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[Configuration globalConfig] objectForKey:@"magestore_buy_url"]]];
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
