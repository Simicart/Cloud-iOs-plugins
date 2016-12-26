//
//  LocationViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 4/21/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "LocationViewController.h"
#import "Location.h"
#import "LocationCollection.h"

@interface LocationViewController()
@property (strong, nonatomic) NSIndexPath *curIndex;
@end

@implementation LocationViewController
@synthesize formData, infoViewController, curIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Location", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[LocationCollection allLocation] getSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"LocationCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    Location *location = [[LocationCollection allLocation] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [location objectForKey:@"name"];
    if ([[location getId] integerValue] == [[formData objectForKey:@"location_id"] integerValue]) {
        curIndex = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *location = [[LocationCollection allLocation] objectAtIndex:[indexPath row]];
    if ([[location getId] integerValue] != [[formData objectForKey:@"location_id"] integerValue]) {
        [formData setValue:[location getId] forKeyPath:@"location_id"];
        [infoViewController.tableView reloadData];
        if (curIndex) {
            [tableView cellForRowAtIndexPath:curIndex].accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
