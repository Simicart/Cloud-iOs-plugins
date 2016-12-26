//
//  SelectCategoryViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "SelectCategoryViewController.h"
#import "Utilities.h"
#import "Category.h"

@interface SelectCategoryViewController ()
@property (strong, nonatomic) SVInfiniteScrollingView *loadingAnimation;
@property (strong, nonatomic) id successObserver, failObserver;
@end

@implementation SelectCategoryViewController
@synthesize loadingAnimation;
@synthesize successObserver, failObserver;

@synthesize productController;
@synthesize popoverController;
@synthesize categories;

- (id)init
{
    if (self = [super init]) {
        self.categories = [[CategoryCollection alloc] init];
        self.loadingAnimation = [[SVInfiniteScrollingView alloc] initWithFrame:CGRectZero];
        [self.tableView addSubview:self.loadingAnimation];
    }
    return self;
}

- (CGSize)reloadContentSize
{
    if (!self.categories.loadCollectionFlag) {
        // Load Category
        successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"CollectionCategoryLoadAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
            self.loadingAnimation.frame = CGRectZero;
            [self.loadingAnimation stopAnimating];
            // Reload popover
            self.popoverController.popoverContentSize = [self reloadContentSize];
            [self.popoverController presentPopoverFromRect:[self.productController.navigationItem.titleView bounds] inView:self.productController.navigationItem.titleView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }];
        failObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
            // Fail to load - Show alert
            NSDictionary *userInfo = [note userInfo];
            if ([userInfo objectForKey:@"reason"] != nil) {
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
            }
            // Dismiss popover
            [self.popoverController dismissPopoverAnimated:YES];
        }];
        [[[NSThread alloc] initWithTarget:self.categories selector:@selector(load) object:nil] start];
        // Show animation
        self.view.frame = CGRectMake(0, 0, 320, 44);
        self.loadingAnimation.frame = self.view.frame;
        [self.loadingAnimation startAnimating];
    }
    CGFloat height = 44;
    if ([categories getSize]) {
        height += 44 * [categories getSize];
    }
    if (height > 528) {
        height = 528;
    }
   // self.contentSizeForViewInPopover = CGSizeMake(320, height);
   // [self.tableView reloadData];
   // return self.contentSizeForViewInPopover;
    
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
    if ([self.categories getSize]) {
        if (section) {
            return [self.categories getSize];
        }
        return 1;
    }
    return 0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if ([categories getSize] && section) {
//        return NSLocalizedString(@"Category", nil);
//    }
//    return @"";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([indexPath section] == 0) {
        cell.textLabel.text = NSLocalizedString(@"All Products", nil);
        cell.accessoryView = nil;
        return cell;
    }
    Category *category = [categories objectAtIndex:[indexPath row]];
    BOOL isParent = NO;
    if ([indexPath row] + 1 < [categories count]) {
        Category *nextCategory = [categories objectAtIndex:([indexPath row] + 1)];
        if ([category getLevel] < [nextCategory getLevel]) {
            isParent = YES;
        }
    }
    if (isParent) {
        UIImageView *disclosureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure_indicator_down.png"]];
        cell.accessoryView = disclosureView;
    } else {
        cell.accessoryView = nil;
    }
    NSString *categoryName = [category getName];
    NSUInteger level = [category getLevel] - [[categories rootCategory] getLevel] - 1;
    NSMutableString *title = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < level; i++) {
        [title appendString:@"    "];
    }
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:(18 - level)]];
    [title appendString:categoryName];
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]) {
        Category *category = [categories objectAtIndex:[indexPath row]];
        [self.productController didSelectCategory:category];
    } else {
        [self.productController didSelectCategory:nil];
    }
    [self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Popover controller delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Reset view button here
    
    // Remove Observers
    if (successObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
    }
    if (failObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
    }
    self.loadingAnimation.frame = CGRectZero;
    [self.loadingAnimation stopAnimating];
}

@end
