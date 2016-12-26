//
//  EditItemOptionsDetail.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/7/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "EditItemOptionsMaster.h"
#import "EditItemOptionsDetail.h"

@implementation EditItemOptionsDetail

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [super tableView:tableView willDisplayHeaderView:view forSection:section];
    if (self.masterControl.view.hidden) {
        [view addSubview:[(EditItemOptionsMaster *)self.masterControl backButton]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [super tableView:tableView titleForHeaderInSection:section];
    if (self.masterControl.view.hidden) {
        return [NSString stringWithFormat:@"       %@", title];
    }
    return title;
}

@end
