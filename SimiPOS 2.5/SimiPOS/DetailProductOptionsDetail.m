//
//  DetailProductOptionsDetail.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/16/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "DetailProductOptionsDetail.h"

@implementation DetailProductOptionsDetail
@synthesize popoverController;

- (CGSize)reloadContentSize
{
    CGFloat width = 320;
    CGFloat height = 44;
    if ([[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]) {
        width = 234;
        height = 218;
        self.tableView.scrollEnabled = NO;
    } else {
        NSDictionary *optionValues = [self productOptionsValue];
        height *= [[optionValues allKeys] count];
        if (height < 132) {
            height = 132;
        }
        self.tableView.scrollEnabled = YES;
    }
//    self.contentSizeForViewInPopover = CGSizeMake(width, height);
//    return self.contentSizeForViewInPopover;
    
    self.preferredContentSize = CGSizeMake(width, height);
    return self.preferredContentSize;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (![[self.detailOptions objectForKey:@"type"] isEqualToString:@"checkbox"]
        && ![[self.detailOptions objectForKey:@"type"] isEqualToString:@"multiple"]
    ) {
        // Dismiss Popover
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
}

@end
