//
//  OrderPrintViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/26/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "UIView+InputNotification.h"
#import "UIImageView+WebCache.h"
#import "OrderPrintViewController.h"
#import "MSFramework.h"
#import "Configuration.h"

#import "Store.h"
#import "Price.h"
#import "Quote.h"

@interface OrderPrintViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;

- (BOOL)needLoadData;
- (NSArray *)storeAddress;
- (NSArray *)customerInfo;
@end

@implementation OrderPrintViewController
@synthesize animation;
@synthesize order = _order;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.bounds = CGRectMake(0, 0, 454, 584);
    
	// Navigation Title & Buttons
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPrint)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Print Order # %@", nil), [self.order getIncrementId]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *printBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printOrderAction)];
    self.navigationItem.rightBarButtonItem = printBtn;
    
    // Order Table View
    self.tableView = [[UITableView alloc] initWithFrame:CGRectInset(self.view.bounds, 11, 22) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    if ([self needLoadData]) {
        [self loadOrderDetailView];
    } else {
        [self.tableView reloadData];
    }
}

- (void)cancelPrint
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)needLoadData
{
    if ([self.order objectForKey:@"items"] == nil) {
        return YES;
    }
    Store *store = [Store currentStore];
    if ([store isLoaded]) {
        return NO;
    }
    return YES;
}

#pragma mark - load order detail view
- (void)loadOrderDetailView
{
    if (![self needLoadData]) {
        return;
    }
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        animation.frame = self.view.bounds;
        animation.color = [UIColor grayColor];
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadOrderDetailThread) object:nil] start];
}

- (void)loadOrderDetailThread
{
    // Load info from server
    if ([self.order objectForKey:@"items"] == nil) {
        [self.order load:[self.order getIncrementId]];
    }
    Store *store = [Store currentStore];
    if (![store isLoaded]) {
        [store load:nil];
    }
    // reload table data and stop animation
    [self.tableView reloadData];
    [animation stopAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

#pragma mark - print order
- (void)printOrderAction
{
    if ([self needLoadData]) {
        return [self loadOrderDetailView];
    }
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    controller.delegate = self;
    controller.printingItem = [UIImage imageNamed:@"product_placeholder.png"];
    
    UIPrintInfo *info = [UIPrintInfo printInfo];
    info.outputType = UIPrintInfoOutputGeneral;
    info.jobName = [self.order getIncrementId];
    info.orientation = UIPrintInfoOrientationPortrait;
    info.printerID = [[Configuration globalConfig] objectForKey:@"printer_id"];
    controller.printInfo = info;
    
    [controller presentFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
        if (!completed && error) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[error localizedDescription]];
        } else if (completed) {
            if (![[[Configuration globalConfig] objectForKey:@"printer_id"] isEqualToString:printInteractionController.printInfo.printerID]) {
                [[Configuration globalConfig] setValue:printInteractionController.printInfo.printerID forKey:@"printer_id"];
            }
            [self cancelPrint];
        }
    }];
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList
{
    CGFloat paperWidth = 0;
    if ([[[Configuration globalConfig] objectForKey:@"manual_print"] boolValue]) {
        if ([[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue]) {
            paperWidth = [[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue];
        } else {
            paperWidth = 58; // mm
        }
        paperWidth = paperWidth * 96 / 25.4; // pixel, inch
    }
    CGFloat bestWidth = (paperWidth > 0.1) ? paperWidth : 264;
    UIPrintPaper *paper = [UIPrintPaper bestPaperForPageSize:CGSizeMake(bestWidth, bestWidth * 1.2) withPapersFromArray:paperList];
    
    // Pdf Item
    CGRect bounds = self.view.bounds;
    self.view.bounds = CGRectMake(0, 0, bounds.size.width - 22, self.tableView.contentSize.height + 44);
    self.tableView.frame = CGRectInset(self.view.bounds, 0, 22);
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    header.backgroundColor = [UIColor whiteColor];
    UIView *footer = [header clone];
    [self.view addSubview:header];
    [self.view addSubview:footer];
    
    NSMutableData *pdfData = [NSMutableData new];
    CGRect pdfPageBounds = CGRectMake(0, 0, paper.paperSize.width, paper.paperSize.height);
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil);
    
    paperWidth = (paperWidth > 0.1) ? paperWidth : paper.paperSize.width;
    
    CGFloat scale = paperWidth / bounds.size.width;
    CGFloat maxHeight = self.view.bounds.size.height - 22;
    CGFloat pageHeight = paper.paperSize.height / scale - 44;
    for (CGFloat pageOriginY = 0; pageOriginY < maxHeight; pageOriginY += pageHeight) {
        header.frame = CGRectMake(0, pageOriginY, bounds.size.width, 20);
        footer.frame = CGRectMake(0, pageOriginY + pageHeight + 24, bounds.size.width, 20);
        
        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -pageOriginY);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }
    
    UIGraphicsEndPDFContext();
    
    [header removeFromSuperview];
    [footer removeFromSuperview];
    self.view.bounds = bounds;
    self.tableView.frame = CGRectInset(self.view.bounds, 11, 22);
    
    printInteractionController.printingItem = pdfData;
    return paper;
}

#pragma mark - table view datasource (order detail)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self needLoadData]) {
        return 0;
    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    switch (section) {
        case 0:
            rows = 2;
            if ([self.order objectForKey:@"invoice_id"]) {
                rows++;
            }
            if ([[self customerInfo] count]) {
                rows++;
            }
            return rows;
        case 1:
            return [[self.order objectForKey:@"items"] count];
        case 2:
            return [[[self.order objectForKey:@"totals"] allKeys] count] + 1;
        case 3:
            if ([self.order objectForKey:@"total_refunded"]) {
                return 2;
            }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"OrderItemsPrint";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    UIFont *printSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Medium" size:23];
    UIFont *smallSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Medium" size:20];
    UIFont *boldSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Demi Bold" size:23];
    UIFont *largeSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Demi Bold" size:26];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        // Cell Width: 432 Points
        UIFont *printFont = printSystemFont;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = printSystemFont;
        cell.textLabel.shadowOffset = CGSizeMake(0, 0);
        cell.detailTextLabel.font = smallSystemFont;
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, 0);
        cell.detailTextLabel.numberOfLines = 2;
        
        UIImageView *storeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 432, 54)];
        storeLogo.contentMode = UIViewContentModeCenter;
        storeLogo.tag = 1;
        [cell addSubview:storeLogo];
        
        UILabel *storeAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 412, 36)];
        storeAddress.numberOfLines = 0;
        storeAddress.font = printFont;
        storeAddress.shadowOffset = CGSizeMake(0, 0);
        storeAddress.tag = 2;
        storeAddress.textAlignment = NSTextAlignmentCenter;
        storeAddress.text = @"";
        [cell addSubview:storeAddress];
        
        UILabel *invoiceId = [storeAddress clone];
        invoiceId.font = largeSystemFont; //[UIFont boldSystemFontOfSize:20];
        invoiceId.shadowOffset = CGSizeMake(0, 0);
        invoiceId.tag = 3;
        [cell addSubview:invoiceId];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 152, 29)];
        priceLabel.font = printFont;
        priceLabel.shadowOffset = CGSizeMake(0, 0);
        priceLabel.textAlignment = NSTextAlignmentRight;
        cell.accessoryView = priceLabel;
        UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 29)];
        qtyLabel.font = printFont;
        qtyLabel.shadowOffset = CGSizeMake(0, 0);
        qtyLabel.textAlignment = NSTextAlignmentCenter;
        qtyLabel.tag = 100;
        [cell.accessoryView addSubview:qtyLabel];
        
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 288, 29)];
        totalLabel.font = printFont;
        totalLabel.shadowOffset = CGSizeMake(0, 0);
        totalLabel.textAlignment = NSTextAlignmentRight;
        totalLabel.tag = 4;
        totalLabel.numberOfLines = 2;
        UILabel *totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(292, 4, 130, 29)];
        totalPrice.font = printFont;
        totalPrice.shadowOffset = CGSizeMake(0, 0);
        totalPrice.textAlignment = NSTextAlignmentRight;
        totalPrice.tag = 5;
        [cell addSubview:totalLabel];
        [cell addSubview:totalPrice];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 432, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
        separator.tag = 6;
        [cell addSubview:separator];
    }
    for (NSUInteger i = 1; i < 7; i++) {
        UILabel *label = (UILabel *)[cell viewWithTag:i];
        label.hidden = YES;
        if ([label isKindOfClass:[UILabel class]]) {
            label.text = nil;
        }
    }
    
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryView.hidden = YES;
    cell.imageView.image = nil;
    if ([indexPath section] == 0) {
        // Store information
        if ([indexPath row] == 0) {
            // Store Logo
            Store *store = [Store currentStore];
            [cell viewWithTag:1].hidden = NO;
            [((UIImageView *)[cell viewWithTag:1]) setImageWithURL:[NSURL URLWithString:[store objectForKey:@"print_logo"]]];
        } else if ([indexPath row] == 1) {
            // Store Address
            UILabel *storeAddress = (UILabel *)[cell viewWithTag:2];
            storeAddress.hidden = NO;
            storeAddress.textAlignment = NSTextAlignmentCenter;
            NSArray *addresses = [self storeAddress];
            storeAddress.text = [addresses componentsJoinedByString:@"\n"];
            storeAddress.frame = CGRectMake(10, 0, 412, 29 * [addresses count]);
        } else if (([indexPath row] == 2 && [MSValidator isEmptyString:[self.order objectForKey:@"invoice_id"]])
            || [indexPath row] == 3
        ) {
            // Customer Information
            UILabel *storeAddress = (UILabel *)[cell viewWithTag:2];
            storeAddress.hidden = NO;
            storeAddress.textAlignment = NSTextAlignmentLeft;
            NSArray *addresses = [self customerInfo];
            storeAddress.text = [addresses componentsJoinedByString:@"\n"];
            storeAddress.frame = CGRectMake(10, 0, 412, 29 * [addresses count]);
        } else {
            // Invoice ID
            UILabel *invoiceId = (UILabel *)[cell viewWithTag:3];
            invoiceId.hidden = NO;
            invoiceId.text = [NSString stringWithFormat:NSLocalizedString(@"Invoice # %@", nil), [self.order objectForKey:@"invoice_id"]];
        }
        return cell;
    }
    if ([indexPath row] == 0) {
        [cell viewWithTag:6].hidden = NO;
    }
    if ([indexPath section] == 2) {
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:4];
        UILabel *totalAmount = (UILabel *)[cell viewWithTag:5];
        totalAmount.font = boldSystemFont; //[UIFont systemFontOfSize:18];
        totalLabel.hidden = NO;
        totalAmount.hidden = NO;
        
        NSDictionary *totals = [self.order objectForKey:@"totals"];
        if ([indexPath row] == [[totals allKeys] count]) {
            // Grand total
            totalLabel.text = NSLocalizedString(@"Grand Total", nil);
            totalAmount.text = [Price format:[self.order objectForKey:@"grand_total"]];
        } else {
            NSDictionary *total = [totals objectForKey:[[[totals allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[indexPath row]]];
            
            totalLabel.text = NSLocalizedString([total objectForKey:@"title"], nil);
            totalAmount.text = [Price format:[total objectForKey:@"amount"]];
        }
        return cell;
    }
    if ([indexPath section] == 3) {
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:4];
        UILabel *totalAmount = (UILabel *)[cell viewWithTag:5];
        totalAmount.font = boldSystemFont; //[UIFont boldSystemFontOfSize:18];
        totalLabel.hidden = NO;
        totalAmount.hidden = NO;
        
        if ([indexPath row]) {
            totalLabel.text = NSLocalizedString(@"Total Refunded", nil);
            totalAmount.text = [Price format:[self.order objectForKey:@"total_refunded"]];
        } else {
            totalLabel.text = NSLocalizedString(@"Total Paid", nil);
            totalAmount.text = [Price format:[self.order objectForKey:@"total_paid"]];
        }
        return cell;
    }
    if ([indexPath section] == 4) {
        // Signature of invoice / order
        [cell viewWithTag:6].hidden = YES;
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Order # %@", nil), [self.order getIncrementId]];
        cell.textLabel.text = [NSString stringWithFormat:@" \n%@   %@", text, [MSDateTime formatDateTime:[self.order objectForKey:@"created_at"]]];
        cell.accessoryView.frame = CGRectMake(0, 0, 1, 1);
        return cell;
    }
    
    cell.accessoryView.frame = CGRectMake(0, 0, 152, 29);
    cell.accessoryView.hidden = NO;
    UILabel *itemPrice = (UILabel *)cell.accessoryView;
    UILabel *itemQty = (UILabel *)[itemPrice viewWithTag:100];
    QuoteItem *item = [[self.order objectForKey:@"items"] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [item getName];
    if (item.options) {
        cell.detailTextLabel.text = [item getOptionsLabel];
    }
    if ([[item objectForKey:@"qty_invoiced"] floatValue] > 0.0001) {
        itemQty.text = [NSString stringWithFormat:@"%.0f", [[item objectForKey:@"qty_invoiced"] floatValue]];
    } else {
        itemQty.text = [NSString stringWithFormat:@"%.0f", [[item objectForKey:@"qty_ordered"] floatValue]];
    }
    itemPrice.text = [Price format:[item getPrice]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([indexPath row] == 1) {
            return 29 * [[self storeAddress] count] + 10;
        }
        if ([indexPath row] == 2) {
            if ([self.order objectForKey:@"invoice_id"]) {
                return 36;
            } else {
                return 29 * [[self customerInfo] count] + 10;
            }
        }
        if ([indexPath row] == 3) {
            return 29 * [[self customerInfo] count] + 10;
        }
        return 70;
    }
    if ([indexPath section] == 1) {
        return 91; //66 + 5;
    }
    if ([indexPath section] == 4) {
        return 60;
    }
    return 45; //30 + 5;
}

- (NSArray *)storeAddress
{
    Store *store = [Store currentStore];
    NSMutableArray *addresses = [NSMutableArray new];
    [addresses addObject:[store objectForKey:@"name"]];
    if ([[store objectForKey:@"address"] isKindOfClass:[NSString class]]) {
        [addresses addObjectsFromArray:[[store objectForKey:@"address"] componentsSeparatedByString:@"\n"]];
    }
    if ([store objectForKey:@"phone"]
        && [[store objectForKey:@"phone"] isKindOfClass:[NSString class]]
        && ![[store objectForKey:@"phone"] isEqualToString:@""]
        ) {
        [addresses addObject:[NSLocalizedString(@"Tel  ", nil) stringByAppendingString:[store objectForKey:@"phone"]]];
    }
    return addresses;
}

- (NSArray *)customerInfo
{
    NSMutableArray *customer = [NSMutableArray new];
    if (![MSValidator isEmptyString:[self.order objectForKey:@"customer_name"]]) {
        [customer addObject:[NSLocalizedString(@"Customer Name: ", nil) stringByAppendingString:[self.order objectForKey:@"customer_name"]]];
    }
    if (![MSValidator isEmptyString:[self.order objectForKey:@"customer_telephone"]]) {
        [customer addObject:[NSLocalizedString(@"Phone / Email: ", nil) stringByAppendingString:[self.order objectForKey:@"customer_telephone"]]];
    } else if (![MSValidator isEmptyString:[self.order objectForKey:@"customer_email"]]) {
        [customer addObject:[NSLocalizedString(@"Phone / Email: ", nil) stringByAppendingString:[self.order objectForKey:@"customer_email"]]];
    }
    return customer;
}

@end
