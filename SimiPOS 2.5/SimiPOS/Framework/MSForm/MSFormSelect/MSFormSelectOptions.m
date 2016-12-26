//
//  MSFormSelectOptions.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/26/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormSelectOptions.h"

@implementation MSFormSelectOptions
@synthesize selectInput, selectedOptions;
@synthesize dataSource, currentKeys;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (CGSize)reloadContentSize
{
    CGFloat height = 44;
    NSUInteger rows = [[self.selectInput.dataSource allKeys] count];
    if (rows && rows < 7) {
        height *= rows;
    } else if (rows > 6) {
        height *= 7;
    }
    //self.contentSizeForViewInPopover = CGSizeMake(240, height);
    //return self.contentSizeForViewInPopover;
    //Gin edit
    [self setPreferredContentSize:CGSizeMake(300, height)];
    //End
    return self.preferredContentSize;
}

- (void)reloadData
{
    [self.tableView reloadData];
    if ([self.selectedOptions count]) {
        id selected = [self.selectedOptions objectAtIndex:0];
        for (NSInteger i = 0; i < [[self.selectInput.dataSource allKeys] count]; i++) {
            if ([selected isEqual:[[self sortedKeysArray] objectAtIndex:i]]) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                return;
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.selectInput.dataSource allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"SelectOptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    id optionValue = [[self sortedKeysArray] objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [self.selectInput.dataSource objectForKey:optionValue];
    //Gin add
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",[optionValue uppercaseString]]];
    //End
    if ([self isSelected:optionValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

// Check option values is selected
- (BOOL)isSelected:(id)option
{
    if ([self.selectedOptions count]) {
        for (id selected in self.selectedOptions) {
            if ([selected isEqual:option]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update input value
    id optionValue = [[self sortedKeysArray] objectAtIndex:[indexPath row]];
    [self.selectInput updateSelectInput:@[optionValue]];
    
    // Dismiss popover
    [self.selectInput.optionsPopover dismissPopoverAnimated:YES];
}

#pragma mark - Sort by display name
- (NSArray *)sortedKeysArray
{
    if ([self.selectInput.dataSource isEqual:dataSource]) {
        return currentKeys;
    }
    dataSource = self.selectInput.dataSource;
    NSArray *keys = [dataSource allKeys];
    currentKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *title1 = [dataSource objectForKey:obj1];
        NSString *title2 = [dataSource objectForKey:obj2];
        return [title1 compare:title2 options:NSNumericSearch];
    }];
    return currentKeys;
}

@end
