//
//  SelectCategoryViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/23/2016.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import "SelectCategoryViewController.h"

@interface SelectCategoryViewController ()
@property (strong, nonatomic) SVInfiniteScrollingView *loadingAnimation;
@property (strong, nonatomic) id successObserver, failObserver;
@end

@implementation SelectCategoryViewController
@synthesize loadingAnimation;
@synthesize successObserver, failObserver;

@synthesize productCollectionViewVC;
@synthesize popoverController;
@synthesize categories;

- (id)init
{
    if (self = [super init]) {
        self.categories = [MRCategory MR_findAllSortedBy:@"order_index" ascending:YES];
        self.loadingAnimation = [[SVInfiniteScrollingView alloc] initWithFrame:CGRectZero];
        [self.tableView addSubview:self.loadingAnimation];
    }
    return self;
}

- (CGSize)reloadContentSize
{
    CGFloat height = 44;
    if (categories && categories.count >0) {
        height += 44 * categories.count;
    }
    if (height > 528) {
        height = 528;
    }
    self.preferredContentSize = CGSizeMake(320, height);
     [self.tableView reloadData];
    return self.preferredContentSize;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }
    
    if (categories && categories.count >0) {
        return categories.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CategoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([indexPath section] == 0) {
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        cell.textLabel.text = NSLocalizedString(@"All Products", nil);
        cell.accessoryView = nil;
        return cell;
    }
    MRCategory *mrCategory = [categories objectAtIndex:[indexPath row]];
    
    if (mrCategory.is_parrent.boolValue) {
        //UIImageView *disclosureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure_indicator_down.png"]];
        UIImageView *disclosureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down4"]];
        cell.accessoryView = disclosureView;
         [cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
    } else {
        cell.accessoryView = nil;
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    }
    
    NSString *categoryName = mrCategory.name;
    NSUInteger level = mrCategory.level.integerValue;
    
    NSMutableString *title = [[NSMutableString alloc] init];
    for (NSUInteger i = 1; i < level; i++) {
        [title appendString:@"    "];
    }

    [title appendString:categoryName];
    cell.textLabel.text = title;
        
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]) {
        MRCategory *mrCategory = [categories objectAtIndex:[indexPath row]];
        [self.productCollectionViewVC didSelectCategory:mrCategory];
    } else {
        [self.productCollectionViewVC didSelectCategory:nil];
    }
    [self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Popover controller delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{

    self.loadingAnimation.frame = CGRectZero;
    [self.loadingAnimation stopAnimating];
}

@end
