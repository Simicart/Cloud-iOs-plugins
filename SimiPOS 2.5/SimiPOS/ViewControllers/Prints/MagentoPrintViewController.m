//
//  MagentoPrintViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 4/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MagentoPrintViewController.h"
#import "MSFramework.h"
#import "Configuration.h"
#import "UIImageView+WebCache.h"

@interface MagentoPrintViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;

@property (strong, nonatomic) UIView *invisibleView;
@property (strong, nonatomic) UIScrollView *scrollView;
- (BOOL)needLoadData;
- (void)showPrintOrderDetail;
@end

@implementation MagentoPrintViewController
@synthesize order = _order, animation;
@synthesize invisibleView, scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.bounds = CGRectMake(0, 0, 769, 702);
    
    // Container and scroll view
    invisibleView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:invisibleView];
    
    scrollView = [[UIScrollView alloc] initWithFrame:invisibleView.bounds];
    [invisibleView addSubview:scrollView];
    
    // Navigation Title & Buttons
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPrint)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Print Order # %@", nil), [self.order getIncrementId]];
    
    UIBarButtonItem *printBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printOrderAction)];
    self.navigationItem.rightBarButtonItem = printBtn;
    
    // Load order detail view
    [self loadOrderDetailView];
}

- (void)cancelPrint
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)needLoadData
{
    if ([self.order objectForKey:@"items_header"] == nil) {
        return YES;
    }
    return NO;
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
    [self.order loadPrintData];
    if ([self needLoadData]) {
        [animation stopAnimating];
        return;
    }
    // Show PDF document
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self performSelectorOnMainThread:@selector(showPrintOrderDetail) withObject:nil waitUntilDone:YES];
    [animation stopAnimating];
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
    UIPrintPaper *paper = [UIPrintPaper bestPaperForPageSize:CGSizeMake(793, 1122) withPapersFromArray:paperList];
    
    // Start to Print
    CGRect inFrame = invisibleView.frame;
    CGRect scFrame = scrollView.frame;
    invisibleView.frame = CGRectMake(0, 0, 793, scrollView.contentSize.height);
    scrollView.frame = CGRectMake(12, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    
    // Print PDF A4
    NSMutableData *pdfData = [NSMutableData new];
    CGRect pdfPageBounds = CGRectMake(0, 0, 793, 1122);
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil);
    for (CGFloat y = 0; y < scrollView.contentSize.height; y += 1125) {
        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, - y);
        
        [invisibleView.layer renderInContext:UIGraphicsGetCurrentContext()];
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }
    UIGraphicsEndPDFContext();
    
    // End Print
    invisibleView.frame = inFrame;
    scrollView.frame = scFrame;
    
    printInteractionController.printingItem = pdfData;
    return paper;
}

#pragma mark - view print form detail
- (void)showPrintOrderDetail
{
    NSArray *invoices = [self.order objectForKey:@"invoices"];
    for (NSUInteger i = 0; i < [invoices count]; i++) {
        NSDictionary *invoice = [invoices objectAtIndex:i];
        UIView *page = [self newPage];
        
        CGFloat height = 26;
        // Add Header Logo and Address
        if (![MSValidator isEmptyString:[self.order objectForKey:@"print_logo"]]) {
            UIImageView *storeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(21, 16, 200, 64)];
            [storeLogo setImageWithURL:[NSURL URLWithString:[self.order objectForKey:@"print_logo"]]];
            storeLogo.contentMode = UIViewContentModeLeft;
            [page addSubview:storeLogo];
            height = 74;
        }
        
        if (![MSValidator isEmptyString:[self.order objectForKey:@"print_address"]]) {
//        if ([self.order objectForKey:@"print_address"]) {
            UITextView *printAddress = [[UITextView alloc] initWithFrame:CGRectMake(514, 26, 234, 20)];
            printAddress.text = [[self.order objectForKey:@"print_address"] componentsJoinedByString:@"\n"];
            printAddress.font = [UIFont systemFontOfSize:12];
            printAddress.textAlignment = NSTextAlignmentRight;
            [printAddress setEditable:NO];
            [page addSubview:printAddress];
            
            //printAddress.frame = CGRectMake(514, 26, 234, printAddress.contentSize.height);
            
            CGFloat width =CGRectGetWidth(printAddress.frame);
            CGSize newSize =[printAddress sizeThatFits:CGSizeMake(width, CGRectGetHeight(printAddress.frame))];
            CGRect newFrame =printAddress.frame;
            newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
            printAddress.frame=newFrame;
            
            
            if (height < newSize.height + 42) {
                height = newSize.height + 42;
            }
        }
        
        // PDF Invoice Header
        UIView *invoiceHeader = [[UIView alloc] initWithFrame:CGRectMake(21, height, 727, 10)];
        [invoiceHeader.layer setBorderColor:[UIColor borderColor].CGColor];
        [invoiceHeader.layer setBorderWidth:1.0];
        invoiceHeader.backgroundColor = [UIColor grayColor];
        [page addSubview:invoiceHeader];
        
        UITextView *headerText = [[UITextView alloc] initWithFrame:CGRectMake(1, 1, 725, 10)];
        headerText.text = [[invoice objectForKey:@"header"] componentsJoinedByString:@"\n"];
        headerText.font = [UIFont boldSystemFontOfSize:13];
        [headerText setEditable:NO];
        [invoiceHeader addSubview:headerText];
        headerText.backgroundColor = [UIColor grayColor];
        headerText.textColor = [UIColor whiteColor];
        
        CGFloat width =CGRectGetWidth(headerText.frame);
        CGSize newSize =[headerText sizeThatFits:CGSizeMake(width, CGRectGetHeight(headerText.frame))];
        //CGRect newFrame =headerText.frame;
        //newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
        //headerText.frame=newFrame;
        
        headerText.frame = CGRectMake(1, 1, 725, newSize.height);
        
        invoiceHeader.frame = CGRectMake(21, height, 727, newSize.height + 2);
        
        
        height += invoiceHeader.bounds.size.height;
        
        // Order Info
        NSArray *orderInfo = [self.order objectForKey:@"order_info"];
        for (NSUInteger j = 0; j < [orderInfo count]; j++) {
            NSDictionary *left = [orderInfo objectAtIndex:j];
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, height-1, 364, 30)];
            headerLabel.text = [NSString stringWithFormat:@"  %@",[left objectForKey:@"header"]];
            headerLabel.font = [UIFont boldSystemFontOfSize:15];
            headerLabel.backgroundColor = [UIColor backgroundColor];
            [headerLabel.layer setBorderColor:[UIColor borderColor].CGColor];
            [headerLabel.layer setBorderWidth:1.0];
            [page addSubview:headerLabel];
            j++;
            NSDictionary *right = [orderInfo objectAtIndex:j];
            headerLabel = [headerLabel clone];
            headerLabel.frame = CGRectMake(384, height-1, 364, 30);
            headerLabel.text = [NSString stringWithFormat:@"  %@",[right objectForKey:@"header"]];
            [headerLabel.layer setBorderColor:[UIColor borderColor].CGColor];
            [headerLabel.layer setBorderWidth:1.0];
            [page addSubview:headerLabel];
            height += 29;
            // Order Info Detail
            UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(21, height, 727, 9)];
            [detailView.layer setBorderColor:[UIColor borderColor].CGColor];
            [detailView.layer setBorderWidth:1.0];
            [page addSubview:detailView];
            
            UITextView *detailText = [[UITextView alloc] initWithFrame:CGRectMake(1, 1, 362, 9)];
            detailText.text = [[left objectForKey:@"text"] componentsJoinedByString:@"\n"];
            detailText.font = [UIFont systemFontOfSize:13];
            [detailText setEditable:NO];
            [detailView addSubview:detailText];
            //CGFloat detailTextHeight = detailText.contentSize.height;
           // detailText.frame = CGRectMake(1, 1, 362, detailTextHeight);
            
            CGFloat width =CGRectGetWidth(detailText.frame);
            CGSize newSize =[detailText sizeThatFits:CGSizeMake(width, CGRectGetHeight(detailText.frame))];
            CGRect newFrame =detailText.frame;
            newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
            detailText.frame=newFrame;
            
            CGFloat detailTextHeight = newSize.height;
            
            detailText = [detailText clone];
            detailText.text = [[right objectForKey:@"text"] componentsJoinedByString:@"\n"];
            [detailView addSubview:detailText];
            
             width =CGRectGetWidth(detailText.frame);
             newSize =[detailText sizeThatFits:CGSizeMake(width, CGRectGetHeight(detailText.frame))];
             newFrame =detailText.frame;
            newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
            //detailText.frame=newFrame;
            
            if (detailTextHeight < newSize.height) {
                detailTextHeight = newSize.height;
            }
            detailText.frame = CGRectMake(364, 1, 362, detailTextHeight);
            
            detailView.frame = CGRectMake(21, height-1, 727, detailTextHeight + 2);
            height += detailView.bounds.size.height + 10;
        }
        
        // Invoice Items
        [self drawItemHeader:page height:&height];
        NSArray *items = [invoice objectForKey:@"items"];
        for (NSUInteger j = 0; j < [items count]; j++) {
            page = [self drawInvoiceItem:[items objectAtIndex:j] onPage:page height:&height];
        }
        
        // Invoice Totals
        height += 20;
        for (NSDictionary *total in [invoice objectForKey:@"totals"]) {
            if (height + 20 > 1096) {
                page = [self newPage];
                height = 36;
            }
            // Total Label
            UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, height + 2, 600, 16)];
            totalLabel.font = [UIFont boldSystemFontOfSize:13];
            totalLabel.textAlignment = NSTextAlignmentRight;
            totalLabel.text = [total objectForKey:@"label"];
            [page addSubview:totalLabel];
            // Total Amount
            totalLabel = [totalLabel clone];
            totalLabel.frame = CGRectMake(621, height + 2, 115, 16);
            totalLabel.text = [total objectForKey:@"amount"];
            [page addSubview:totalLabel];
            
            height += 20;
        }
    }
}

- (UIView *)newPage
{
    if (scrollView.contentSize.height < 1122) {
        scrollView.contentSize = CGSizeMake(769, 1122);
        UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 769, 1122)];
        [scrollView addSubview:pageView];
        return pageView;
    }
    // Draw separator
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, scrollView.contentSize.height + 1, scrollView.contentSize.width, 1)];
    [separator setBackgroundColor:[UIColor lightBorderColor]];
    [scrollView addSubview:separator];
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollView.contentSize.height + 3, scrollView.contentSize.width, 1122)];
    [scrollView addSubview:pageView];
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + 1125);
    return pageView;
}

- (void)drawItemHeader:(UIView *)page height:(CGFloat *)height
{
    *height += 10;
    NSArray *headerData = [self.order objectForKey:@"items_header"];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(21, *height, 727, 20)];
    [header.layer setBorderColor:[UIColor borderColor].CGColor];
    [header.layer setBorderWidth:1.0];
    header.backgroundColor = [UIColor backgroundColor];
    [page addSubview:header];
    *height += 30;
    
    // Each Label
    CGFloat start = 12;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(start, 2, 256, 16)];
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.backgroundColor = [UIColor backgroundColor];
    
    // Products
    headerLabel.text = [headerData objectAtIndex:0];
    [header addSubview:headerLabel];
    start += 256;
    
    // SKU
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:1];
    headerLabel.textAlignment = NSTextAlignmentRight;
    headerLabel.frame = CGRectMake(start, 2, 105, 16);
    [header addSubview:headerLabel];
    start += 105;
    
    // Price
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:3];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.frame = CGRectMake(start, 2, 120, 16);
    [header addSubview:headerLabel];
    start += 120;
    
    // Qty
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:2];
    headerLabel.frame = CGRectMake(start, 2, 72, 16);
    [header addSubview:headerLabel];
    start += 72;
    
    // Tax
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:4];
    headerLabel.frame = CGRectMake(start, 2, 81, 16);
    [header addSubview:headerLabel];
    start += 81;
    
    // Subtotal
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:5];
    headerLabel.textAlignment = NSTextAlignmentRight;
    headerLabel.frame = CGRectMake(start, 2, 69, 16);
    [header addSubview:headerLabel];
}

- (UIView *)drawInvoiceItem:(NSArray *)item onPage:(UIView *)page height:(CGFloat *)height
{
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(21, *height, 727, 16)];
    [page addSubview:itemView];
    CGFloat x = 0, y = 0;
    
    // Product Name
    NSDictionary *productName = [item objectAtIndex:0];
    CGFloat delta = -7;
    if ([productName objectForKey:@"name"]) {
        delta = 0;
        UITextView *name = [[UITextView alloc] initWithFrame:CGRectMake(x, y, 268, 10)];
        name.text = [productName objectForKey:@"name"];
        name.font = [UIFont systemFontOfSize:13];
        [name setEditable:NO];
        [itemView addSubview:name];
        name.frame = CGRectMake(x, y, 268, name.contentSize.height);
        y += name.contentSize.height;
    }
    x += 12;
    if ([productName objectForKey:@"options"]) {
        NSArray *options = [productName objectForKey:@"options"];
        for (NSDictionary *option in options) {
            // Title
            if ([option objectForKey:@"title"]) {
                UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(0, y-7, 268, 9)];
                title.text = [option objectForKey:@"title"];
                title.font = [UIFont italicSystemFontOfSize:13];
                [title setEditable:NO];
                [itemView addSubview:title];
                title.frame = CGRectMake(0, y-7, 268, title.contentSize.height);
                y += title.contentSize.height - 7;
            }
            // Value
            if ([option objectForKey:@"value"]) {
                UITextView *value = [[UITextView alloc] initWithFrame:CGRectMake(x, y-7, 256, 9)];
                value.text = [[option objectForKey:@"value"] componentsJoinedByString:@"\n"];
                value.font = [UIFont systemFontOfSize:13];
                [value setEditable:NO];
                [itemView addSubview:value];
                value.frame = CGRectMake(x, y-7, 256, value.contentSize.height);
                y += value.contentSize.height - 7;
            }
        }
        y += 7;
    }
    x += 256;
    
    // SKU
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    content.font = [UIFont systemFontOfSize:13];
    [content setEditable:NO];
    content.textAlignment = NSTextAlignmentRight;
    content.frame = CGRectMake(x, delta, 105, 9);
    content.text = [item objectAtIndex:1];
    [itemView addSubview:content];
    content.frame = CGRectMake(x, delta, 112, content.contentSize.height);
    x += 105;
    if (y < content.contentSize.height) {
        y = content.contentSize.height;
    }
    
    // Price
    content = [content clone];
    content.frame = CGRectMake(x, delta, 120, 9);
    content.font = [UIFont boldSystemFontOfSize:13];
    content.text = [[item objectAtIndex:3] componentsJoinedByString:@"\n"];
    [itemView addSubview:content];
    content.frame = CGRectMake(x, delta, 120, content.contentSize.height);
    x += 120;
    if (y < content.contentSize.height) {
        y = content.contentSize.height;
    }
    
    // Qty
    content = [content clone];
    content.textAlignment = NSTextAlignmentCenter;
    content.frame = CGRectMake(x, delta, 72, 9);
    content.font = [UIFont systemFontOfSize:13];
    content.text = [item objectAtIndex:2];
    [itemView addSubview:content];
    content.frame = CGRectMake(x, delta, 72, content.contentSize.height);
    x += 72;
    if (y < content.contentSize.height) {
        y = content.contentSize.height;
    }
    
    // Tax
    content = [content clone];
    content.frame = CGRectMake(x, delta, 81, 9);
    content.font = [UIFont boldSystemFontOfSize:13];
    content.text = [item objectAtIndex:4];
    [itemView addSubview:content];
    content.frame = CGRectMake(x, delta, 81, content.contentSize.height);
    x += 81;
    if (y < content.contentSize.height) {
        y = content.contentSize.height;
    }
    
    // Subtotal
    content = [content clone];
    content.textAlignment = NSTextAlignmentRight;
    content.frame = CGRectMake(x, delta, 81, 9);
    content.text = [[item objectAtIndex:5] componentsJoinedByString:@"\n"];
    [itemView addSubview:content];
    content.frame = CGRectMake(x, delta, 81, content.contentSize.height);
    x += 81;
    if (y < content.contentSize.height) {
        y = content.contentSize.height;
    }
    
    itemView.frame = CGRectMake(21, *height, 727, y);
    return [self checkNewPage:page forView:itemView height:height];
}

- (UIView *)checkNewPage:(UIView *)page forView:(UIView *)view height:(CGFloat *)height
{
    if (*height + view.bounds.size.height < 1097) {
        *height += view.bounds.size.height;
        return page;
    }
    // Create New Page
    UIView *newPage = [self newPage];
    *height = 26;
    // Add Header
    [self drawItemHeader:newPage height:height];
    // Move view to new page
    [view removeFromSuperview];
    CGRect frame = view.frame;
    view.frame = CGRectMake(frame.origin.x, *height, frame.size.width, frame.size.height);
    [newPage addSubview:view];
    *height += frame.size.height;
    
    return newPage;
}

@end
