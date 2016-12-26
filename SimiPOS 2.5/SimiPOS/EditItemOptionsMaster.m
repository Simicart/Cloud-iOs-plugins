//
//  EditItemOptionsMaster.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "EditItemOptionsMaster.h"

@implementation EditItemOptionsMaster
@synthesize backButtonView;

- (UIButton *)backButton
{
    if (backButtonView == nil) {
        backButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButtonView setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        backButtonView.frame = CGRectMake(0, 5, 44, 36);
        
        [backButtonView addTarget:self action:@selector(backToEditItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return backButtonView;
}

- (IBAction)backToEditItem
{
    EditItemViewController *editItem = (EditItemViewController *)self.navigationController.delegate;
    [editItem rePresentPopover:[editItem reloadContentSize]];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - update shopping cart item
- (IBAction)doneEditOptions:(id)sender
{
    // Validate Option
    EditItemOptions *editItemOptions = (EditItemOptions *)self.parentViewController;
    if (![editItemOptions validateOptions]) {
        return;
    }
    
    // Update shopping cart item
    EditItemViewController *editItem = (EditItemViewController *)self.navigationController.delegate;
    [editItem updateQuoteItem:editItemOptions.productOptions];
    
    // Back to edit item
    [self backToEditItem];
    
    UITableViewCell *cell = [editItem.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    QuoteItem *tempItem = [[QuoteItem alloc] init];
    tempItem.product = editItem.item.product;
    tempItem.options = (NSMutableDictionary *)editItemOptions.productOptions;
    cell.detailTextLabel.text = [tempItem getOptionsLabel];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [super tableView:tableView willDisplayHeaderView:view forSection:section];
    [view addSubview:[self backButton]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"       %@", [super tableView:tableView titleForHeaderInSection:section]];
}

@end
