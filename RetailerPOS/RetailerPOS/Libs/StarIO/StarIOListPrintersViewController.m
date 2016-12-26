//
//  StarIOListPrintersViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 7/19/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StarIOListPrintersViewController.h"

@implementation StarIOListPrintersViewController {
    UIActivityIndicatorView *animation;
    NSArray *foundPrinters;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.contentSizeForViewInPopover = CGSizeMake(320, 220);
    self.preferredContentSize = CGSizeMake(320, 220);
    
    // Show Animation
    animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    animation.frame = CGRectMake(0, 0, 320, 44);
    [self.view addSubview:animation];
    [animation startAnimating];
    // Search printer
    [[[NSThread alloc] initWithTarget:self selector:@selector(searchPrinters) object:nil] start];
}

- (void)searchPrinters
{
    foundPrinters = [SMPort searchPrinter:@"TCP:"];
//    // Test printer
//    PortInfo *newPort = [[PortInfo alloc] initWithPortName:@"TCP:192.168.1.58" macAddress:@"AB:CD:EF:1B:CD:2A" modelName:@"Star TSP100LAN"];
//    foundPrinters = @[newPort];
//    
    [animation stopAnimating];
    if ([foundPrinters count]) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    } else {
        // Show "No printer found"
        UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 320, 34)];
        noLabel.font = [UIFont systemFontOfSize:16];
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.text = NSLocalizedString(@"No Printers Found", nil);
        [self.view addSubview:noLabel];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [foundPrinters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarIOPrinter"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"StarIOPrinter"];
    }
    PortInfo *port = [foundPrinters objectAtIndex:indexPath.row];
    cell.textLabel.text = port.modelName;
    cell.detailTextLabel.text = port.portName;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PortInfo *port = [foundPrinters objectAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate selectPrinterPort:port];
    }
    // Back to parent
    [self.navigationController popViewControllerAnimated:YES];
}

@end
