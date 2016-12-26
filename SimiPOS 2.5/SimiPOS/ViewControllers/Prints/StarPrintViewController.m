//
//  StarPrintViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 7/18/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StarPrintViewController.h"
#import "Utilities.h"
#import "UIImageView+WebCache.h"
#import "UIView+InputNotification.h"
#import "MSFramework.h"
#import <QuartzCore/QuartzCore.h>

#import "Store.h"
#import "Price.h"
#import "Quote.h"
#import "Configuration.h"

@implementation StarPrintViewController {
    UIView *invisibleView, *scrollView;
    UIActivityIndicatorView *animation;
    UITextView *printText;
}
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.bounds = CGRectMake(0, 0, 454, 584);
    
    // Container and scroll view
    invisibleView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:invisibleView];
    
    scrollView = [[UIScrollView alloc] initWithFrame:invisibleView.bounds];
    [invisibleView addSubview:scrollView];
    
    printText = [UITextView new];
    [scrollView addSubview:printText];
    
    // Navigation Title & Buttons
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPrint)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Print Order # %@", nil), [self.order getIncrementId]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *printBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printOrderAction)];
    self.navigationItem.rightBarButtonItem = printBtn;
    
    // Load order detail view
    //    [self loadOrderDetailView];
    
    // Order Table View - OLD FORM
    self.tableView = [[UITableView alloc] initWithFrame:CGRectInset(self.view.bounds, 11, 22) style:UITableViewStylePlain];
    [self.tableView setContentInset:UIEdgeInsetsMake(22, 0, 0, 0)];
    
    
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
    //    if ([self.order objectForKey:@"items_header"] == nil) {
    //        return YES;
    //    }
    //    return NO;
    // OLD FORM
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
    //    [self.order loadPrintData];
    //    if ([self needLoadData]) {
    //        [animation stopAnimating];
    //        return;
    //    }
    //    // Show PDF document
    //    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    //    [self performSelectorOnMainThread:@selector(showPrintOrderDetail) withObject:nil waitUntilDone:YES];
    //    [animation stopAnimating];
    
    // OLD FORM
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

#pragma mark - Star TSP100LAN print
- (void)printOrderAction
{
    StarIOPrinterViewController *controller = [StarIOPrinterViewController sharePrinterViewController];
    controller.delegate = self;
    [controller presentFromBarButtonItem:self.navigationItem.rightBarButtonItem completionHandler:^(StarIOPrinterViewController *printViewController, BOOL completed, NSString *error) {
        // Complete print
        if (completed) {
            [self cancelPrint];
        } else if (error) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:error];
        }
    }];
}

- (UIImage *)printViewController:(StarIOPrinterViewController *)printViewController
{
    UIGraphicsBeginImageContext(self.tableView.contentSize);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    NSUInteger numberofSection = 5;
    NSUInteger rows = 0;
    
    for (int section = 0; section < numberofSection; section++) {
        switch (section) {
            case 0:
                rows = 2;
                if ([self.order objectForKey:@"invoice_id"]) {
                    rows++;
                }
                if ([[self customerInfo] count]) {
                    rows++;
                }
            case 1:
                rows = [[self.order objectForKey:@"items"] count];
            case 2:
                rows = [[[self.order objectForKey:@"totals"] allKeys] count] + 1;
            case 3:
                if ([self.order objectForKey:@"total_refunded"]) {
                    rows = 2;
                }
            default: rows = 1;
        }
        
        for (int row = 0; row < rows; row ++ ) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return image;
    

    
    // OLD FORM
    CGFloat scale = 576 / self.tableView.contentSize.width;
    
    CGSize messuredSize = CGSizeMake(576, self.tableView.contentSize.height * scale);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
        } else {
            UIGraphicsBeginImageContext(messuredSize);
        }
    } else {
        UIGraphicsBeginImageContext(messuredSize);
    }
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width + 1, messuredSize.height + 1);
    CGContextFillRect(ctr, rect);
    CGContextScaleCTM(ctr, scale, scale);
    [self.tableView.layer renderInContext:ctr];
    
    color = [UIColor blackColor];
    [color set];
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return imageToPrint;
    
    
    // NEW
    //    NSString *textToPrint = printText.text;
    //
    //    NSString *fontName = @"Courier";
    //    double fontSize = 24.0;
    //
    //    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    //
    //    CGSize size = CGSizeMake(576, 10000);
    //    CGSize messuredSize = [textToPrint sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    //
    //	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    //		if ([[UIScreen mainScreen] scale] == 2.0) {
    //			UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
    //		} else {
    //			UIGraphicsBeginImageContext(messuredSize);
    //		}
    //	} else {
    //		UIGraphicsBeginImageContext(messuredSize);
    //	}
    //
    //    CGContextRef ctr = UIGraphicsGetCurrentContext();
    //    UIColor *color = [UIColor whiteColor];
    //    [color set];
    //
    //    CGRect rect = CGRectMake(0, 0, messuredSize.width + 1, messuredSize.height + 1);
    //    CGContextFillRect(ctr, rect);
    //
    //    color = [UIColor blackColor];
    //    [color set];
    //    [textToPrint drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping];
    //
    //    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    //
    //    UIGraphicsEndImageContext();
    //    return imageToPrint;
}

#pragma mark - show print order detail
- (void)showPrintOrderDetail
{
    printText.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    printText.text = @"Test printer";
}

#pragma mark - table view datasource (order detail) | OLD FORM
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
    
    //    UIFont *printSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Medium" size:23];
    //    UIFont *smallSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Medium" size:20];
    //    UIFont *boldSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Demi Bold" size:23];
    //    UIFont *largeSystemFont = [UIFont fontWithName:@"Avenir Next Condensed Demi Bold" size:26];
    UIFont *printSystemFont = [UIFont fontWithName:@"Courier" size:16];
    UIFont *smallSystemFont = [UIFont fontWithName:@"Courier" size:13];
    UIFont *boldSystemFont = [UIFont fontWithName:@"Courier Bold" size:16];
    UIFont *largeSystemFont = [UIFont fontWithName:@"Courier Bold" size:18];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        // Cell Width: 432 Points
        UIFont *printFont = printSystemFont;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.font = printSystemFont;
        cell.textLabel.shadowOffset = CGSizeMake(0, 0);
        cell.detailTextLabel.font = smallSystemFont;
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, 0);
        cell.detailTextLabel.numberOfLines = 2;
        
        UIImageView *storeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 432, 54)];
        storeLogo.contentMode = UIViewContentModeCenter;
        storeLogo.contentMode = UIViewContentModeScaleAspectFit;
        storeLogo.tag = 1;
        [cell addSubview:storeLogo];
        
        UILabel *storeAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 412, 27)];
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
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 152, 24)];
        priceLabel.font = printFont;
        priceLabel.shadowOffset = CGSizeMake(0, 0);
        priceLabel.textAlignment = NSTextAlignmentRight;
        cell.accessoryView = priceLabel;
        UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 24)];
        qtyLabel.font = printFont;
        qtyLabel.shadowOffset = CGSizeMake(0, 0);
        qtyLabel.textAlignment = NSTextAlignmentCenter;
        qtyLabel.tag = 100;
        [cell.accessoryView addSubview:qtyLabel];
        
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 288, 24)];
        totalLabel.font = boldSystemFont;
        totalLabel.shadowOffset = CGSizeMake(0, 0);
        totalLabel.textAlignment = NSTextAlignmentRight;
        totalLabel.tag = 4;
        totalLabel.numberOfLines = 2;
        UILabel *totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(292, 4, 130, 24)];
        totalPrice.font = boldSystemFont;
        totalPrice.shadowOffset = CGSizeMake(0, 0);
        totalPrice.textAlignment = NSTextAlignmentRight;
        totalPrice.tag = 5;
        [cell addSubview:totalLabel];
        [cell addSubview:totalPrice];
        
        UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 412, 27)];
        footer.frame = CGRectMake(5, 0, 422, 30);
        footer.tag = 7;
        footer.textAlignment = NSTextAlignmentLeft;
        footer.lineBreakMode = NSLineBreakByClipping;
        [cell addSubview:footer];
        
        
        UILabel *thankFooter = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 412, 27)];
        thankFooter.frame = CGRectMake(5, 35, 422, 30);
        thankFooter.tag = 8;
        thankFooter.textAlignment = NSTextAlignmentCenter;
        thankFooter.lineBreakMode = NSLineBreakByClipping;
        [cell addSubview:thankFooter];
        
        UILabel *extraFooter = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 412, 27)];
        extraFooter.frame = CGRectMake(5, 65, 422, 30);
        extraFooter.tag = 9;
        extraFooter.textAlignment = NSTextAlignmentCenter;
        extraFooter.lineBreakMode = NSLineBreakByClipping;
        [cell addSubview:extraFooter];
        
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 432, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
        separator.tag = 6;
        [cell addSubview:separator];
    }
    for (NSUInteger i = 1; i < 9; i++) {
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
            storeAddress.frame = CGRectMake(10, 0, 412, 24 * [addresses count]);
        } else if (([indexPath row] == 2 && [MSValidator isEmptyString:[self.order objectForKey:@"invoice_id"]])
                   || [indexPath row] == 3
                   ) {
            // Customer Information
            UILabel *storeAddress = (UILabel *)[cell viewWithTag:2];
            //Ravi
            Store *store = [Store currentStore];
            if ([store objectForKey:@"hidden_customer_info"]) {
                storeAddress.hidden = YES;
            }else{
                storeAddress.hidden = NO;
            }
            storeAddress.textAlignment = NSTextAlignmentLeft;
            NSArray *addresses = [self customerInfo];
            storeAddress.text = [addresses componentsJoinedByString:@"\n"];
            storeAddress.frame = CGRectMake(10, 0, 412, 24 * [addresses count]);
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
        totalLabel.hidden = NO;
        totalAmount.hidden = NO;
        
        NSDictionary *totals = [self.order objectForKey:@"totals"];
        if ([indexPath row] == [[totals allKeys] count]) {
            // Grand total
            totalLabel.text = NSLocalizedString(@"Grand Total", nil);
            totalAmount.text = [Price format:[MSValidator isEmptyString:[self.order objectForKey:@"grand_total"]] ? 0 : [self.order objectForKey:@"grand_total"]];
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
        totalLabel.hidden = NO;
        totalAmount.hidden = NO;
        
        if ([indexPath row]) {
            totalLabel.text = NSLocalizedString(@"Total Refunded", nil);
            totalAmount.text = [Price format:[MSValidator isEmptyString:[self.order objectForKey:@"total_refunded"]] ? 0 : [self.order objectForKey:@"total_refunded"]];
        } else {
            totalLabel.text = NSLocalizedString(@"Total Paid", nil);
            totalAmount.text = [Price format:[MSValidator isEmptyString:[self.order objectForKey:@"total_paid"]] ? 0 :[self.order objectForKey:@"total_paid"]];
        }
        return cell;
    }
    if ([indexPath section] == 4) {
        // Signature of invoice / order
        [cell viewWithTag:6].hidden = YES;
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Order # %@", nil), [self.order getIncrementId]];
        ((UILabel *)[cell viewWithTag:7]).hidden = NO;
        ((UILabel *)[cell viewWithTag:7]).text = [NSString stringWithFormat:@"%@  %@", text, [MSDateTime formatDateTime:[MSValidator isEmptyString:[self.order objectForKey:@"created_at"]] ? @"" : [self.order objectForKey:@"created_at"]]];
        cell.accessoryView.frame = CGRectMake(0, 0, 1, 1);
        
        
        //Ravi
        Store *store = [Store currentStore];
        if ([store objectForKey:@"name_footer_star"]) {
            ((UILabel *)[cell viewWithTag:8]).hidden = NO;
            ((UILabel *)[cell viewWithTag:8]).text = [NSString stringWithFormat:@"Thank you for shopping at %@",[store objectForKey:@"name_footer_star"]];
            ((UILabel *)[cell viewWithTag:8]).font = smallSystemFont;
            if ([store objectForKey:@"extra_footer"]) {
                ((UILabel *)[cell viewWithTag:9]).hidden = NO;
                ((UILabel *)[cell viewWithTag:9]).text = [store objectForKey:@"extra_footer"];
                ((UILabel *)[cell viewWithTag:9]).font = smallSystemFont;
            }
        }
        //End
        
        return cell;
    }
    
    cell.accessoryView.frame = CGRectMake(0, 0, 152, 24);
    cell.accessoryView.hidden = NO;
    UILabel *itemPrice = (UILabel *)cell.accessoryView;
    UILabel *itemQty = (UILabel *)[itemPrice viewWithTag:100];
    
    
    
    //Ravi fix bug starPrint
    QuoteItem *item = [QuoteItem new];
    if ([[self.order objectForKey:@"items"] isKindOfClass:[NSArray class]]) {
        item = [[self.order objectForKey:@"items"] objectAtIndex:[indexPath row]];
    }else {
        NSMutableArray *items = [NSMutableArray new];
        for (NSString *key in [[self.order objectForKey:@"items"] allKeys]) {
            [items addObject:[[self.order objectForKey:@"items"] objectForKey:key]];
        }
        item = [items objectAtIndex:[indexPath row]];
    }
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",item]);
    //    cell.textLabel.text = [item getName];
    cell.textLabel.text = [item valueForKey:@"name"];
    
    //    if (item.options) {
    //        cell.detailTextLabel.text = [item getOptionsLabel];
    //    }
    
    if ([[[item objectForKey:@"product_data"]valueForKey:@"has_options"] boolValue]) {
        //        cell.detailTextLabel.text = [item getOptionsLabel];
        NSMutableArray *labels = [[NSMutableArray alloc] init];
        NSMutableArray *optionList = [NSMutableArray new];
        
        [optionList addObjectsFromArray:[item objectForKey:@"options"]];
        
        //    for (NSDictionary *option in [self.product getOptions]) {
        for (NSDictionary *option in optionList) {
            //End
            NSString *optionLabel = [self getOptionLabel:option item:item];
            if (optionLabel != nil) {
                [labels addObject:optionLabel];
            }
        }
        if ([labels count]) {
            cell.detailTextLabel.text = [labels componentsJoinedByString:@", "];
        }
    }
    
    if ([[item objectForKey:@"qty_invoiced"] floatValue] > 0.0001) {
        itemQty.text = [NSString stringWithFormat:@"%.0f", [[item objectForKey:@"qty_invoiced"] floatValue]];
    } else {
        itemQty.text = [NSString stringWithFormat:@"%.0f", [[item objectForKey:@"qty_ordered"] floatValue]];
    }
    //    itemPrice.text = [Price format:[item getPrice]];
    itemPrice.text = [Price format:[NSNumber numberWithDouble:[[item valueForKey:@"price"] doubleValue]]];
    
    //End fix bug starPrint
    return cell;
}


//Ravi
- (NSString *)getOptionLabel:(NSDictionary *)option item:(NSDictionary *)item
{
    id selectedOption = [item objectForKey:@"selected_options"];
    if (selectedOption == nil) {
        return nil;
    }
    if ([[option objectForKey:@"group"] isEqualToString:@"date"]
        || [[option objectForKey:@"group"] isEqualToString:@"text"]
        ) {
        if ([selectedOption isKindOfClass:[NSString class]]) {
            return selectedOption;
        }
        NSString *result;
        if ([selectedOption objectForKey:@"day"]) {
            result = [NSString stringWithFormat:@"%@-%@-%@", [selectedOption objectForKey:@"year"], [selectedOption objectForKey:@"month"], [selectedOption objectForKey:@"day"]];
        }
        if ([selectedOption objectForKey:@"hour"]) {
            if (result) {
                result = [result stringByAppendingString:[NSString stringWithFormat:@" %@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]]];
            } else {
                result = [NSString stringWithFormat:@"%@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]];
            }
        }
        return result;
    }
    NSDictionary *optionValues = [option objectForKey:@"values"];
    if ([selectedOption isKindOfClass:[NSArray class]]) {
        NSMutableArray *optionTitles = [[NSMutableArray alloc] init];
        for (id valueId in selectedOption) {
            [optionTitles addObject:[[optionValues objectForKey:valueId] objectForKey:@"title"]];
        }
        return [optionTitles componentsJoinedByString:@", "];
    }
    if ([optionValues count]) {
        
        if([selectedOption isKindOfClass:[NSNumber class]]){
            
            NSString * keyOption =[NSString stringWithFormat:@"%@",selectedOption];
            return [[optionValues objectForKey:keyOption] objectForKey:@"title"];
        }
        return [[optionValues objectForKey:selectedOption] objectForKey:@"title"];
    }
    return selectedOption;
}
//End

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Store *store = [Store currentStore];
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 1) {
            return 24 * [[self storeAddress] count] + 7;
        }
        if ([indexPath row] == 2) {
            if ([self.order objectForKey:@"invoice_id"]) {
                return 27;
            } else {
//                Ravi
                if ([store objectForKey:@"hidden_customer_info"]) {
                    return 7;
                }
                return 24 * [[self customerInfo] count] + 7;
            }
        }
        if ([indexPath row] == 3) {
            //Ravi
            if ([store objectForKey:@"hidden_customer_info"]) {
                return 7;
            }
            return 24 * [[self customerInfo] count] + 7;
        }
        return 60;
    }
    if ([indexPath section] == 1) {
        return 72; //66 + 5;
    }
    if ([indexPath section] == 4) {
        //Ravi
        
        if ([store objectForKey:@"name_footer_star"]) {
            if ([store objectForKey:@"extra_footer"]) {
                return 96;
            }
            return 66;
        }
        //End
        return 49;
    }
    
    return 36; //30 + 5;
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
