//
//  StarIOPrinterViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 7/18/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StarIOPrinterViewController.h"
#import "RasterDocument.h"
#import "StarBitmap.h"
#import "Configuration.h"

@implementation StarIOPrinterViewController {
    starPrintCompleteBlock completeBlock;
    UIPopoverController *printPopover;
}

+ (instancetype)sharePrinterViewController
{
    static StarIOPrinterViewController *sharePrinter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePrinter = [[self alloc] initWithStyle:UITableViewStyleGrouped];
    });
    return sharePrinter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Printer Options", nil);
//    [self.tableView setScrollEnabled:NO];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"Printer", nil);
        cell.detailTextLabel.text = [[Configuration globalConfig] objectForKey:@"tsp_modelName"];
        if (cell.detailTextLabel.text == nil) {
            cell.detailTextLabel.text = NSLocalizedString(@"Select Printer", nil);
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Open Cash Drawer", nil);
        if ([[[Configuration globalConfig] objectForKey:@"open_cash_drawer"] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 34)];
        textLabel.highlightedTextColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont boldSystemFontOfSize:18];
        textLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
        textLabel.text = NSLocalizedString(@"Print", nil);
        [cell addSubview:textLabel];
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // Show select printer form
        StarIOListPrintersViewController *searchPrinter = [StarIOListPrintersViewController new];
        searchPrinter.delegate = self;
        [self.navigationController pushViewController:searchPrinter animated:YES];
    } else if (indexPath.section == 1) {
        // Toogle open cash drawer
        if ([[[Configuration globalConfig] objectForKey:@"open_cash_drawer"] boolValue]) {
            [[Configuration globalConfig] removeObjectForKey:@"open_cash_drawer"];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        } else {
            [[Configuration globalConfig] setValue:[NSNumber numberWithBool:YES] forKey:@"open_cash_drawer"];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        // Print & open cash drawer
        @try {
            [self PrintImageWithPortname:[[Configuration globalConfig] objectForKey:@"tsp_portName"] portSettings:@"Standard" imageToPrint:[self.delegate printViewController:self] maxWidth:576 compressionEnable:YES withDrawerKick:[[[Configuration globalConfig] objectForKey:@"open_cash_drawer"] boolValue]];
            completeBlock(self, YES, nil);
            [printPopover dismissPopoverAnimated:YES];
        }
        @catch (NSException *exception) {
            completeBlock(self, NO, exception.reason);
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Printer functions
- (void)PrintImageWithPortname:(NSString *)portName portSettings:(NSString*)portSettings imageToPrint:(UIImage*)imageToPrint maxWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable withDrawerKick:(BOOL)drawerKick
{
    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];
    
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    if (drawerKick == YES) {
        [commandsToPrint appendBytes:"\x07" length:sizeof("\x07") - 1]; // KickCashDrawer
    }
    
    [self sendCommand:commandsToPrint portName:portName portSettings:portSettings timeoutMillis:10000];
}

- (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings timeoutMillis:(u_int32_t)timeoutMillis
{
    int commandSize = (int)[commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil) {
            [NSException raise:@"Fail to Open Port" format:NSLocalizedString(@"Fail to Open Port", nil)];
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            [NSException raise:@"Printer is offline" format:NSLocalizedString(@"Printer is offline", nil)];
        }
        
        CFTimeInterval endTime = CACurrentMediaTime() + 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            if (CACurrentMediaTime() > endTime) {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize) {
            [NSException raise:@"Write port timed out" format:NSLocalizedString(@"Write port timed out", nil)];
        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000;
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            [NSException raise:@"Printer is offline" format:NSLocalizedString(@"Printer is offline", nil)];
        }
    }
    @catch (NSException *exception)
    {
        [NSException raise:exception.name format:@"%@", exception.reason];
    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
    }
}

#pragma mark - StarIO list delegate
- (void)selectPrinterPort:(PortInfo *)portInfo
{
    [[Configuration globalConfig] setValue:portInfo.modelName forKey:@"tsp_modelName"];
    [[Configuration globalConfig] setValue:portInfo.portName forKey:@"tsp_portName"];
    // Reload Data
    [self.tableView reloadData];
}

#pragma mark - present printer view controller
- (void)presentFromBarButtonItem:(UIBarButtonItem *)item completionHandler:(starPrintCompleteBlock)completion
{
    completeBlock = completion;
    if (printPopover == nil) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
        printPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    }
   // self.contentSizeForViewInPopover = CGSizeMake(320, 220);
    self.preferredContentSize =CGSizeMake(320, 220+30);
    printPopover.popoverContentSize = CGSizeMake(320, 257+30);
    [printPopover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
