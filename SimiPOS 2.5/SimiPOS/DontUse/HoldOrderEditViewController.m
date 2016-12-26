//
//  OrderEditViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 22/2/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HoldOrderEditViewController.h"
#import "UIImageView+WebCache.h"
#import "Price.h"
#import "MSFramework.h"
#import "HoldOrdersListViewController.h"

#import "Payanywhere.h"
#import "Invoice.h"
#import "Product.h"
#import "QuoteItem.h"
#import "CartItemCell.h"

#import "OrderEmailViewController.h"
//#import "OrderRefundViewController.h"
#import "PartialRefundViewController.h"
#import "OrderPrintViewController.h"
#import "MagentoPrintViewController.h"
#import "StarPrintViewController.h"

#import "OrderNoteViewController.h"
#import "Configuration.h"

#import "ViewController.h"
#import "AppDelegate.h"
#import "MenuItem.h"

@interface HoldOrderEditViewController ()
@property (strong, nonatomic) UIView *clearView;
@property (strong, nonatomic) UILabel *orderTotal, *orderDate, *orderStatus, *totalDue;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UIPopoverController *notePopover;
- (void)showNoteForm:(id)sender;
@property (strong, nonatomic) PartialRefundViewController *refund;
@property (strong, nonatomic) id root;
@property (assign, nonatomic) BOOL  isHoldOrderView;

@end

@implementation HoldOrderEditViewController
@synthesize refund;
@synthesize clearView;
@synthesize orderTotal, orderDate, orderStatus, totalDue;
@synthesize root;

@synthesize animation, notePopover;

@synthesize invoiceBtn, printBtn, emailBtn, refundBtn;

@synthesize listViewController, currentIndexPath;
@synthesize order = _order;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 596, 702);
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.clearView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.clearView setBackgroundColor:[UIColor whiteColor]];
    
    // Navigation button
    MSNoteButton *noteBtn = [MSNoteButton buttonWithType:UIButtonTypeRoundedRect];
    noteBtn.frame = CGRectMake(0, 0, 44, 44);
    [noteBtn addTarget:self action:@selector(showNoteForm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
    
    // Header View
    self.orderTotal = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 576, 40)];
    self.orderTotal.font = [UIFont boldSystemFontOfSize:36];
    self.orderTotal.textAlignment = NSTextAlignmentCenter;
    self.orderTotal.textColor = [UIColor blueColor];
    [self.view addSubview:self.orderTotal];
    
    orderDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 280, 20)];
    orderDate.font = [UIFont systemFontOfSize:16];
    orderDate.textAlignment = NSTextAlignmentRight;
    orderDate.textColor = [UIColor darkGrayColor];
    
    if(self.isHoldOrderView){
        orderDate.text = [NSLocalizedString(@"Hold Order Date", nil) stringByAppendingString:@":"];
    }else{
        orderDate.text = [NSLocalizedString(@"Order Date", nil) stringByAppendingString:@":"];
    }
    
    
    [self.view addSubview:orderDate];
    
    orderDate = [orderDate clone];
    orderDate.frame = CGRectMake(300, 45, 288, 20);
    orderDate.font = [UIFont boldSystemFontOfSize:16];
    orderDate.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:orderDate];
    
    orderStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, 280, 20)];
    orderStatus.font = [UIFont systemFontOfSize:16];
    orderStatus.textAlignment = NSTextAlignmentRight;
    orderStatus.textColor = [UIColor darkGrayColor];
    orderStatus.text = [NSLocalizedString(@"Status", nil) stringByAppendingString:@":"];
    [self.view addSubview:orderStatus];
    
    orderStatus = [orderStatus clone];
    orderStatus.frame = CGRectMake(300, 65, 288, 20);
    orderStatus.font = [UIFont boldSystemFontOfSize:16];
    orderStatus.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:orderStatus];
    
    totalDue = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 280, 20)];
    totalDue.font = [UIFont systemFontOfSize:16];
    totalDue.textAlignment = NSTextAlignmentRight;
    totalDue.textColor = [UIColor darkGrayColor];
    totalDue.text = [NSLocalizedString(@"Total Due", nil) stringByAppendingString:@":"];
    [self.view addSubview:totalDue];
    
    totalDue = [totalDue clone];
    totalDue.frame = CGRectMake(300, 85, 288, 20);
    totalDue.font = [UIFont boldSystemFontOfSize:16];
    totalDue.textAlignment = NSTextAlignmentLeft;
    totalDue.textColor = [UIColor orangeColor];
    totalDue.text = [Price format:[NSNumber numberWithBool:NO]];
    [self.view addSubview:totalDue];
    
    invoiceBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    invoiceBtn.frame = CGRectMake(489, 64, 100, 44);
    [invoiceBtn setTitle:NSLocalizedString(@"Invoice", nil) forState:UIControlStateNormal];
    [self.view addSubview:invoiceBtn];
    [invoiceBtn addTarget:self action:@selector(invoiceOrder) forControlEvents:UIControlEventTouchUpInside];
    
    // Table View (order detail)
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 110, 596, 508) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.separatorColor = self.tableView.backgroundColor;
    [self.view addSubview:self.tableView];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 596, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [self.view addSubview:separator];
    
    // Order Actions
    printBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
    printBtn.frame = CGRectMake(20, 628, 180, 54);
    [printBtn setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];
    printBtn.titleLabel.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:printBtn];
    [printBtn addTarget:self action:@selector(printOrderForm) forControlEvents:UIControlEventTouchUpInside];
    
    emailBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
    emailBtn.frame = CGRectMake(208, 628, 180, 54);
    [emailBtn setTitle:NSLocalizedString(@"Email", nil) forState:UIControlStateNormal];
    emailBtn.titleLabel.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:emailBtn];
    [emailBtn addTarget:self action:@selector(showEmailForm) forControlEvents:UIControlEventTouchUpInside];
    
    refundBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
    refundBtn.frame = CGRectMake(396, 628, 180, 54);
    [refundBtn setTitle:NSLocalizedString(@"Refund", nil) forState:UIControlStateNormal];
    refundBtn.titleLabel.font = [UIFont systemFontOfSize:22];
    [refundBtn setTitleColor:[UIColor borderColor] forState:UIControlStateDisabled];
    [self.view addSubview:refundBtn];
    [refundBtn addTarget:self action:@selector(showRefundForm) forControlEvents:UIControlEventTouchUpInside];
    
    // Show Layout
    [self loadOrderDetailView];
    
    [self hideAndShowButtonForHoldOrders];
}

- (void)assignOrder:(Order *)order
{
    if (order && [order isEqual:self.order]) {
        return;
    }
    if (self.order && order && [[self.order getId] isEqualToString:[order getId]]) {
        [self.order addData:order];
    } else {
        self.order = order;
    }
    [self loadOrderDetailView];
}

- (void)loadOrderDetailView
{
    if (self.order) {
        if(self.isHoldOrderView){
            self.title = [NSString stringWithFormat:NSLocalizedString(@"Hold Order # %@", nil), [self.order objectForKey:@"increment_id"]];
        }else{
            self.title = [NSString stringWithFormat:NSLocalizedString(@"Order # %@", nil), [self.order objectForKey:@"increment_id"]];
        }
        
        [self.clearView removeFromSuperview];
    } else {
        
        if(self.isHoldOrderView){
            self.title = NSLocalizedString(@"Hold Order", nil);
        }else{
            self.title = NSLocalizedString(@"Order", nil);
        }
        
        
        [self.view addSubview:self.clearView];
        return;
    }
    // Header View
    orderTotal.text = [Price format:[self.order objectForKey:@"grand_total"]];
    
    orderDate.text = [MSDateTime formatDateTime:[self.order objectForKey:@"created_at"]];
    
    orderStatus.text = [[self.order objectForKey:@"status"] capitalizedString];
    invoiceBtn.hidden = YES;
    
    // Load Order infomation (if need)
    if ([self.order objectForKey:@"items"] == nil) {
        return [self loadOrder];
    }
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        animation.frame = self.view.bounds;
        animation.color = [UIColor grayColor];
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.view addSubview:animation];
    }
    [[[NSThread alloc] initWithTarget:animation selector:@selector(startAnimating) object:nil] start];
    [self reloadData];
    [animation stopAnimating];
}

- (void)reloadData
{
    if ([self.order canInvoice]) {
        invoiceBtn.hidden = NO;
        
    }
    if ([self.order objectForKey:@"status_label"]) {
        orderStatus.text = [self.order objectForKey:@"status_label"];
    }
    if ([self.order canRefund]) {
        [refundBtn setTitle:NSLocalizedString(@"Refund", nil) forState:UIControlStateNormal];
        [refundBtn setEnabled:YES];
    } else if ([self.order canCancel]) {
        [refundBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [refundBtn setEnabled:YES];
    } else {
        [refundBtn setEnabled:NO];
    }
    totalDue.text = [Price format:[self.order objectForKey:@"total_due"]];
    [self.tableView reloadData];
    
    [self hideAndShowButtonForHoldOrders];
}

#pragma mark - load order
- (void)loadOrder
{
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        animation.frame = self.view.bounds;
        animation.color = [UIColor grayColor];
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadOrderThread) object:nil] start];
}

- (void)loadOrderThread
{
    if ([self.order objectForKey:@"customer_name"]) {
        [self.order setValue:[self.order objectForKey:@"customer_name"] forKey:@"org_customer_name"];
    }
    [self.order load:[self.order getIncrementId]];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [animation stopAnimating];
    if ([currentIndexPath row] >= [listViewController.orderList getSize]) {
        return;
    }
    Order *order = [listViewController.orderList objectAtIndex:[currentIndexPath row]];
    if (![self.order isEqual:order]) {
        return;
    }
    [listViewController.tableView reloadData];
    [listViewController.tableView selectRowAtIndexPath:currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.order objectForKey:@"items"] == nil) {
        return 0;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return [[self.order objectForKey:@"items"] count];
        case 2:
            return [[[self.order objectForKey:@"totals"] allKeys] count];
        case 3:
            if ([self.order objectForKey:@"total_refunded"]) {
                return 3;
            }
            return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"OrderItems";
    CartItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[CartItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.detailTextLabel.numberOfLines = 2;
        
        UILabel *customerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 576, 22)];
        customerLabel.font = [UIFont systemFontOfSize:16];
        customerLabel.textAlignment = NSTextAlignmentCenter;
        customerLabel.tag = 1;
        UILabel *staffLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 33, 576, 22)];
        staffLabel.font = [UIFont systemFontOfSize:16];
        staffLabel.textAlignment = NSTextAlignmentCenter;
        staffLabel.tag = 2;
        staffLabel.textColor = [UIColor darkGrayColor];
        [cell addSubview:customerLabel];
        [cell addSubview:staffLabel];
        
        //        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 22)];
        //        priceLabel.font = [UIFont boldSystemFontOfSize:17];
        //        priceLabel.textAlignment = NSTextAlignmentRight;
        //        cell.accessoryView = priceLabel;
        
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 386, 24)];
        totalLabel.font = [UIFont systemFontOfSize:20];
        totalLabel.textAlignment = NSTextAlignmentRight;
        totalLabel.tag = 3;
        totalLabel.numberOfLines = 2;
        UILabel *totalPrice = [[UILabel alloc] initWithFrame:CGRectMake(406, 5, 180, 24)];
        totalPrice.font = [UIFont boldSystemFontOfSize:20];
        totalPrice.textAlignment = NSTextAlignmentRight;
        totalPrice.tag = 4;
        [cell addSubview:totalLabel];
        [cell addSubview:totalPrice];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 596, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
        separator.tag = 5;
        [cell addSubview:separator];
        
        cell.imageView.transform = CGAffineTransformMakeScale(0.61, 0.61);
    }
    for (NSUInteger i = 1; i < 5; i++) {
        [cell viewWithTag:i].hidden = YES;
        ((UILabel *)[cell viewWithTag:i]).text = nil;
    }
    [cell viewWithTag:5].hidden = NO;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    //    cell.accessoryView.hidden = YES;
    cell.imageView.image = nil;
    [cell addBadgeQty:1.0];
    if ([indexPath section] == 0) {
        UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *detailLabel = (UILabel *)[cell viewWithTag:2];
        textLabel.hidden = NO;
        if ([self.order objectForKey:@"customer_email"]) {
            textLabel.text = [NSString stringWithFormat:@"%@ <%@>", [self.order objectForKey:@"customer_name"], [self.order objectForKey:@"customer_email"]];
            NSMutableAttributedString *customerEmail = [[NSMutableAttributedString alloc] initWithString:textLabel.text];
            [customerEmail addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange([[self.order objectForKey:@"customer_name"] length] + 2, [[self.order objectForKey:@"customer_email"] length])];
            textLabel.attributedText = customerEmail;
            if (![MSValidator isEmptyString:[self.order objectForKey:@"simipos_email"]]) {
                detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sold by %@", nil), [self.order objectForKey:@"simipos_email"]];
                detailLabel.hidden = NO;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sold by %@", nil), [self.order objectForKey:@"simipos_email"]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    
    if ([indexPath section] == 2) {
        if ([indexPath row]) {
            [cell viewWithTag:5].hidden = YES;
        }
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *totalAmount = (UILabel *)[cell viewWithTag:4];
        totalAmount.textColor = [UIColor blackColor];
        totalLabel.hidden = NO;
        totalAmount.hidden = NO;
        
        NSDictionary *totals = [self.order objectForKey:@"totals"];
        NSDictionary *total = [totals objectForKey:[[[totals allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[indexPath row]]];
        
        totalLabel.text = [total objectForKey:@"title"];
        totalAmount.text = [Price format:[total objectForKey:@"amount"]];
        return cell;
    }
    if ([indexPath section] == 3) {
        if ([indexPath row]) {
            [cell viewWithTag:5].hidden = YES;
        }
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *totalAmount = (UILabel *)[cell viewWithTag:4];
        totalAmount.textColor = [UIColor orangeColor];
        totalLabel.hidden = NO;
        totalAmount.hidden = NO;
        
        if ([indexPath row] == 0) {
            totalLabel.text = NSLocalizedString(@"Grand Total", nil);
            totalAmount.text = [Price format:[self.order objectForKey:@"grand_total"]];
        } else if ([indexPath row] == 2) {
            totalLabel.text = NSLocalizedString(@"Total Refunded", nil);
            totalAmount.text = [Price format:[self.order objectForKey:@"total_refunded"]];
        } else {
            totalLabel.text = NSLocalizedString(@"Total Paid", nil);
            totalAmount.text = [Price format:[self.order objectForKey:@"total_paid"]];
        }
        return cell;
    }
    
    //    cell.accessoryView.hidden = NO;
    UILabel *itemPrice = (UILabel *)cell.accessoryView;
    QuoteItem *item = [[self.order objectForKey:@"items"] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [item getName];
    if (item.options) {
        cell.detailTextLabel.text = [item getOptionsLabel];
    }
    [cell.imageView setImageWithURL:[NSURL URLWithString:[item.product objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"product_placeholder.png"]];
    [cell addBadgeQty:[[item objectForKey:@"qty_ordered"] floatValue]];
    itemPrice.text = [Price format:[item getPrice]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([self.order objectForKey:@"customer_email"] == nil
            || [MSValidator isEmptyString:[self.order objectForKey:@"simipos_email"]]
            ) {
            return 44;
        }
        return 66;
    }
    if ([indexPath section] == 1) {
        return 80;
    }
    return 34;
}

#pragma mark - create invoice
- (void)invoiceOrder
{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to invoice this order?", nil) delegate:self cancelButtonTitle:@"" destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [confirm showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        return;
    }
    if ([self.order canCancel] && actionSheet.tag == 101) {
        [animation startAnimating];
        [[[NSThread alloc] initWithTarget:self selector:@selector(cancelOrderThread) object:nil] start];
        return;
    }
    // Create Invoice for Order
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(invoiceOrderThread) object:nil] start];
}

- (void)showPayAnywhereSDK
{
    root = [UIApplication sharedApplication].keyWindow.rootViewController;
    Payanywhere *merchant = (Payanywhere *)[Configuration getSingleton:@"Payanywhere"];
    if (![merchant objectForKey:@"merchant_id"]) {
        [merchant load:nil];
    }
    if (![merchant objectForKey:@"merchant_id"] || ![merchant objectForKey:@"login_id"]
        || ![merchant objectForKey:@"user_name"] || ![merchant objectForKey:@"password"]
        ) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Invalid payment configuration. Please check your settings on your store backend.", nil)];
        return;
    }
    // Basic Information
    [[PATransactionHandler dataHolder] setDelegate:self];
    [[PATransactionHandler dataHolder] setMerchantId:[merchant objectForKey:@"merchant_id"]];
    [[PATransactionHandler dataHolder] setLoginId:[merchant objectForKey:@"login_id"]];
    [[PATransactionHandler dataHolder] setUserName:[merchant objectForKey:@"user_name"]];
    [[PATransactionHandler dataHolder] setPassWord:[merchant objectForKey:@"password"]];
    [[PATransactionHandler dataHolder] setAppName:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]];
    
    // Interface
    {
        //        [[PATransactionHandler dataHolder] setBackgroundImage:                      [UIImage imageNamed:@"background_iPad.png"]];
        //        [[PATransactionHandler dataHolder] setBackgroundImageLandscape:             [UIImage imageNamed:@"background_landscape_iPad.png"]];
        //        [[PATransactionHandler dataHolder] setLogoImage:                            [UIImage imageNamed:@"merchant_logo_iPad.png"]];
        [[PATransactionHandler dataHolder] setLogoImageLandscape:                   [UIImage imageNamed:@"merchant_logo_landscape_iPad.png"]];
        [[PATransactionHandler dataHolder] setBackButtonImage:                      [UIImage imageNamed:@"back_iPad.png"]];
        [[PATransactionHandler dataHolder] setSwipeCardImage:                       [UIImage imageNamed:@"swipeCard_iPad.png"]];
        [[PATransactionHandler dataHolder] setManualEntryBackgroundShort:           [UIImage imageNamed:@"entryShort.png"]];
        [[PATransactionHandler dataHolder] setManualEntryBackgroundShortHighlighted:[UIImage imageNamed:@"entryShortHighlighted.png"]];
        [[PATransactionHandler dataHolder] setManualEntryBackgroundLong:            [UIImage imageNamed:@"entryLong.png"]];
        [[PATransactionHandler dataHolder] setManualEntryBackgroundLongHighlighted: [UIImage imageNamed:@"entryLongHighlighted.png"]];
        [[PATransactionHandler dataHolder] setManuallyEnterImage:                   [UIImage imageNamed:@"enterManually_iPad.png"]];
        [[PATransactionHandler dataHolder] setChargeButtonImage:                    [UIImage imageNamed:@"charge_iPad.png"]];
        [[PATransactionHandler dataHolder] setProcessingImage:                      [UIImage imageNamed:@"processing_iPad.png"]];
        [[PATransactionHandler dataHolder] setApprovedImage:                        [UIImage imageNamed:@"approved_iPad.png"]];
        [[PATransactionHandler dataHolder] setDeclinedImage:                        [UIImage imageNamed:@"declined_iPad.png"]];
        [[PATransactionHandler dataHolder] setOkButtonImage:                        [UIImage imageNamed:@"ok_iPad.png"]];
        [[PATransactionHandler dataHolder] setEmailButtonImage:                     [UIImage imageNamed:@"emailReceipt_iPad.png"]];
        [[PATransactionHandler dataHolder] setNoThanksButtonImage:                  [UIImage imageNamed:@"noThanks_iPad.png"]];
        NSMutableArray *keyPadArrayImages = [[NSMutableArray alloc] init];
        for (int i = 1; i < 10; i++)
            [keyPadArrayImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"0%d.png",i]]];
        [keyPadArrayImages addObject:[UIImage imageNamed:@"00.png"]];
        [keyPadArrayImages addObject:[UIImage imageNamed:@"0.png"]];
        [keyPadArrayImages addObject:[UIImage imageNamed:@"delete.png"]];
        [[PATransactionHandler dataHolder] setKeyPadArrayImages:keyPadArrayImages];
    }
    
    // Color
    {
        [[PATransactionHandler dataHolder] setBackgroundColor:[UIColor blueColor]];
        [[PATransactionHandler dataHolder] setBackButtonColorType:greenColorButton];
        [[PATransactionHandler dataHolder] setNormalColor:[UIColor whiteColor]];
        [[PATransactionHandler dataHolder] setHighlightedColor:[UIColor orangeColor]];
        [[PATransactionHandler dataHolder] setIsBackgroundColorOn:YES];
    }
    [[PATransactionHandler dataHolder] setSupportedOrientations:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft], [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], nil]];
    
    // Configuration
    [[PATransactionHandler dataHolder] setTransactionType:NewChargeTransaction];
    [[PATransactionHandler dataHolder] setIsEmailOn:NO];
    [[PATransactionHandler dataHolder] setIsSignatureOn:YES];
    [[PATransactionHandler dataHolder] setIsSignatureRequired:NO];
    
    // Amount and Invoice ID
    [[PATransactionHandler dataHolder] setAmount:[NSString stringWithFormat:@"%f", [[self.order objectForKey:@"total_due"] doubleValue]]];
    [[PATransactionHandler dataHolder] setInvoice:[self.order objectForKey:@"last_invoice_id"]];
    
    [[PATransactionHandler dataHolder] submit];
}

- (void)transactionResults:(id)response
{
    Invoice *invoice = [Invoice new];
    [invoice setValue:[self.order objectForKey:@"last_invoice_id"] forKey:@"increment_id"];
    if ([[response objectForKey:@"Transaction status"] isEqualToString:@"Approved"]) {
        // Transaction Success > Capture Invoice
        [invoice capture];
        invoiceBtn.hidden = YES;
    } else {
        // Transaction canceled or fail > Cancel Invoice
        [invoice cancel];
    }
    // Reload Order
    [self loadOrder];
    if (![[[UIApplication sharedApplication].keyWindow subviews] count]) {
        [[UIApplication sharedApplication].keyWindow addSubview:[(UIViewController *)root view]];
    }
}

- (void)invoiceOrderThread
{
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Error when query
        NSDictionary *userInfo = [note userInfo];
        if (userInfo == nil) {
            return ;
        }
        id model = [userInfo objectForKey:@"model"];
        if (![self.order isEqual:model]) {
            return ;
        }
        if ([userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
        [animation stopAnimating];
    }];
    
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderCreateInvoiceSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([[self.order objectForKey:@"payment_method"] isEqualToString:@"payanywhere"]) {
            [self performSelectorOnMainThread:@selector(showPayAnywhereSDK) withObject:nil waitUntilDone:YES];
            // [self showPayAnywhereSDK];
        } else {
            invoiceBtn.hidden = YES;
            [self loadOrder];
        }
    }];
    
    [self.order invoice:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

- (void)cancelOrderThread
{
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Error when query
        NSDictionary *userInfo = [note userInfo];
        if (userInfo == nil) {
            return ;
        }
        id model = [userInfo objectForKey:@"model"];
        if (![self.order isEqual:model]) {
            return ;
        }
        if ([userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
        [animation stopAnimating];
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderCancelSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        invoiceBtn.hidden = YES;
        [refundBtn setEnabled:NO];
        [self loadOrder];
    }];
    [self.order cancel];
    
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] || [indexPath row] || [MSValidator isEmptyString:[self.order objectForKey:@"customer_id"]]) {
        return;
    }
    Order *customerOrder = self.order;
    ViewController *rootViewController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
    MenuItem *customerMenu = [rootViewController.menuItems objectAtIndex:3];
    [customerMenu selectStyle];
    [rootViewController didSelectMenuItem:customerMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewOrderCustomerDetail" object:customerOrder];
}

#pragma mark - order actions
- (void)printOrderForm
{
    if ([[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue] == 1) {
        MagentoPrintViewController *print = [MagentoPrintViewController new];
        print.order = [Order new];
        [print.order setValue:[self.order getIncrementId] forKeyPath:@"increment_id"];
        
        MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
        printNav.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:printNav animated:YES completion:nil];
        return;
    }
    UIViewController *print = nil;
    if ([[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue]) {
        print = [OrderPrintViewController new];
        ((OrderPrintViewController *)print).order = self.order;
    } else {
        print = [StarPrintViewController new];
        // Old Form
        ((StarPrintViewController *)print).order = self.order;
        //        ((StarPrintViewController *)print).order = [Order new];
        //        [((StarPrintViewController *)print).order setValue:[self.order getIncrementId] forKey:@"increment_id"];
    }
    MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
    printNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:printNav animated:YES completion:nil];
    printNav.view.superview.frame = CGRectMake(285, 70, 454, 628); // width: 302 ~ 80 mm (1.5)
}

- (void)showEmailForm
{
    OrderEmailViewController *email = [OrderEmailViewController new];
    email.order = self.order;
    MSNavigationController *emailNav = [[MSNavigationController alloc] initWithRootViewController:email];
    emailNav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:emailNav animated:YES completion:nil];
    emailNav.view.superview.frame = CGRectMake(294, 260, 436, 153);
}

- (void)showRefundForm
{
    if ([self.order canCancel]) {
        UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to cancel this order?", nil) delegate:self cancelButtonTitle:@"" destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        confirm.tag = 101;
        [confirm showInView:self.view];
        return;
    }
    refund = [PartialRefundViewController new];
    //    OrderRefundViewController *refund = [OrderRefundViewController new];
    refund.order = self.order;
    refund.editViewController = self;
    MSNavigationController *refundNav = [[MSNavigationController alloc] initWithRootViewController:refund];
    //    refundNav.modalPresentationStyle = UIModalPresentationFormSheet;
    refundNav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:refundNav animated:YES completion:nil];
    //    refundNav.view.superview.frame = CGRectMake(265, 230, 436, 308);
}

#pragma mark - note action
- (void)showNoteForm:(id)sender
{
    if (notePopover == nil) {
        OrderNoteViewController *quoteNote = [OrderNoteViewController new];
        notePopover = [[UIPopoverController alloc] initWithContentViewController:quoteNote];
        notePopover.delegate = quoteNote;
        quoteNote.notePopover = notePopover;
        quoteNote.editViewController = self;
        quoteNote.order = self.order;
    }
    OrderNoteViewController *quoteNote = (OrderNoteViewController *)notePopover.delegate;
    notePopover.popoverContentSize = [quoteNote reloadContentSize];
    [notePopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//ndchien add :
#pragma mark - set type of viewcontroller
-(void)setTypeOfViewController:(BOOL)isHold
{
    self.isHoldOrderView =isHold;
}

#pragma mark - hide button not need to use
-(void)hideAndShowButtonForHoldOrders{
    
    if(self.isHoldOrderView){
        invoiceBtn.hidden =YES;
        printBtn.hidden=YES;
        emailBtn.hidden=YES;
        refundBtn.hidden=YES;
        
    }else{
        
        invoiceBtn.hidden =NO;
        printBtn.hidden=NO;
        emailBtn.hidden=NO;
        refundBtn.hidden=NO;
    }
}

@end
