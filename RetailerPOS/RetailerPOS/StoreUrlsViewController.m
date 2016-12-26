//
//  StoreUrlsViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StoreUrlsViewController.h"

@interface StoreUrlsViewController()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@end

@implementation StoreUrlsViewController
@synthesize loginForm, storeList;
@synthesize animation, currentIndexPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Navigation Button and Title
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelect)];
    
    
    self.title = NSLocalizedString(@"Choose Your Store", nil);
    
    // Table View
    self.tableView.rowHeight = 54;
}

- (void)cancelSelect
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [storeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    NSDictionary *url = [storeList objectAtIndex:[indexPath row]];
    NSString *domain = [url objectForKey:API_URL_NAME];
    cell.textLabel.text = [domain substringToIndex:[domain length]-8];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([[url objectForKey:@"store_plan"] isEqualToString:@"live"]) {
        // Live Image
        cell.imageView.image = [UIImage imageNamed:@"icon_website_liv.png"];
    } else {
        // Dev Image
        cell.imageView.image = [UIImage imageNamed:@"icon_website_dev.png"];
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentIndexPath == nil) {
        currentIndexPath = indexPath;
    } else if (![currentIndexPath isEqual:indexPath]) {
        [tableView cellForRowAtIndexPath:currentIndexPath].accessoryType = UITableViewCellAccessoryNone;
        currentIndexPath = indexPath;
    }
    Configuration *config = [Configuration globalConfig];
    [config addEntriesFromDictionary:[storeList objectAtIndex:[indexPath row]]];
    
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = self.view.bounds;
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(loginToStore) object:nil] start];
}

- (void)loginToStore
{
//    [loginForm loginToStore];
//    [self.navigationItem.leftBarButtonItem setEnabled:YES];
//    [animation stopAnimating];
}

@end
