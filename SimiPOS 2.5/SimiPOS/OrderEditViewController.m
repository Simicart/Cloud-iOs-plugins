//
//  OrderEditViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "OrderEditViewController.h"
#import "UIImageView+WebCache.h"
#import "Price.h"
#import "MSFramework.h"
#import "OrdersListViewController.h"

#import "Payanywhere.h"
#import "Invoice.h"
#import "Product.h"
#import "QuoteItem.h"
#import "CartItemCell.h"

//#import "OrderEmailViewController.h"
//#import "OrderRefundViewController.h"
#import "PartialRefundViewController.h"
#import "OrderPrintViewController.h"
#import "MagentoPrintViewController.h"
#import "StarPrintViewController.h"

#import "OrderNoteViewController.h"
#import "Configuration.h"

//#import "ViewController.h"
//#import "AppDelegate.h"
//#import "MenuItem.h"

#import "Quote.h"
#import "CartViewController.h"
#import "SendEmailVC.h"
#import "ItemsShipVC.h"

#import "DefaultPrintViewVCViewController.h"
#import "QuoteResource.h"
#import "Discount.h"

CGFloat kWidthButton =135;
CGFloat kSpaceBetweenButton =145;
CGFloat kHeightButton =54;

int kBottomSpace =130;

@interface OrderEditViewController ()

@property (strong, nonatomic) UILabel *orderTotal, *orderDate, *orderStatus, *totalDue;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UIControl *loadingMask;
@property (strong, nonatomic) UIPopoverController *notePopover;
- (void)showNoteForm:(id)sender;
@property (strong, nonatomic) PartialRefundViewController *refund;
@property (strong, nonatomic) ItemsShipVC * itemShipVC;
@property (strong, nonatomic) id root;
@property (assign, nonatomic) BOOL  isHoldOrderView;

@end

@implementation OrderEditViewController{
    Permission * permission;
}
@synthesize refund;

@synthesize orderTotal, orderDate, orderStatus, totalDue;
@synthesize root;
@synthesize animation, notePopover;
@synthesize invoiceBtn, printBtn, emailBtn, refundBtn,continueBtn,cancelBtn,shipBtn;
@synthesize listViewController, currentIndexPath;
@synthesize order = _order;
@synthesize tableView = _tableView;
@synthesize itemShipVC;


- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    [parent.view addSubview:self.loadingMask];
}

- (void)startAnimation
{

    [[[NSThread alloc] initWithTarget:self selector:@selector(animationThread) object:nil] start];

}

- (void)animationThread
{
    self.loadingMask.hidden = NO;
    [self.animation startAnimating];
}

- (void)stopAnimation
{
    self.loadingMask.hidden = YES;
    [self.animation stopAnimating];
    
    return;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 596, 702);
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    // Animation

    self.loadingMask = [[UIControl alloc] initWithFrame:self.view.frame];
    self.loadingMask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    self.loadingMask.hidden = YES;
    
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.loadingMask addSubview:self.animation];
    

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
    
    // Table View (order detail)
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 110, 596, WINDOW_HEIGHT -260) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.separatorColor = self.tableView.backgroundColor;
    [self.view addSubview:self.tableView];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 596, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [self.view addSubview:separator];
    
    // 2 choice for create object
    
    if(self.isHoldOrderView){

        
        //Cancel button
        cancelBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        //cancelBtn.frame =  CGRectMake(20, 628, 180, 54);
        cancelBtn.frame =  CGRectMake(20, WINDOW_HEIGHT -kBottomSpace, 180, 54);
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [self.view addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelHoldOrderClick) forControlEvents:UIControlEventTouchUpInside];
        
        //Continue button
        continueBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        continueBtn.frame = CGRectMake(396, WINDOW_HEIGHT -kBottomSpace, 180, 54);
        [continueBtn setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
        continueBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [self.view addSubview:continueBtn];
        //[continueBtn addTarget:self action:@selector(continueHoldOrderClick) forControlEvents:UIControlEventTouchUpInside];
        [continueBtn addTarget:self action:@selector(holdContineOrderProccess) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        
        //Invoice Button
        invoiceBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        invoiceBtn.frame = CGRectMake(489, 64, 100, 40);
        
        [invoiceBtn setTitle:NSLocalizedString(@"Invoice", nil) forState:UIControlStateNormal];
        [self.view addSubview:invoiceBtn];
        [invoiceBtn addTarget:self action:@selector(invoiceOrder) forControlEvents:UIControlEventTouchUpInside];
        
        // Order Actions
        printBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        printBtn.frame = CGRectMake(10, WINDOW_HEIGHT -kBottomSpace, kWidthButton, kHeightButton);
        [printBtn setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];
        printBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [self.view addSubview:printBtn];
        [printBtn addTarget:self action:@selector(printOrderForm) forControlEvents:UIControlEventTouchUpInside];
        
        //Email
        emailBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        emailBtn.frame =  CGRectMake(printBtn.frame.origin.x + kSpaceBetweenButton, WINDOW_HEIGHT -kBottomSpace, kWidthButton, kHeightButton);
        [emailBtn setTitle:NSLocalizedString(@"Email", nil) forState:UIControlStateNormal];
        emailBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [self.view addSubview:emailBtn];
        [emailBtn addTarget:self action:@selector(showEmailForm) forControlEvents:UIControlEventTouchUpInside];
        
        
        //Ship
        shipBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        shipBtn.frame = CGRectMake(emailBtn.frame.origin.x + kSpaceBetweenButton, WINDOW_HEIGHT -kBottomSpace, kWidthButton, kHeightButton);
        [shipBtn setTitle:NSLocalizedString(@"Ship", nil) forState:UIControlStateNormal];
        shipBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [shipBtn setTitleColor:[UIColor borderColor] forState:UIControlStateDisabled];
        [self.view addSubview:shipBtn];
        [shipBtn addTarget:self action:@selector(showShipOrder) forControlEvents:UIControlEventTouchUpInside];
        
        permission =[Permission MR_findFirst];
        
        if(permission.manage_order.boolValue && permission.manage_order_refund.boolValue){
            refundBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
            refundBtn.frame = CGRectMake(shipBtn.frame.origin.x + kSpaceBetweenButton, WINDOW_HEIGHT -kBottomSpace, kWidthButton, kHeightButton);
            [refundBtn setTitle:NSLocalizedString(@"Refund", nil) forState:UIControlStateNormal];
            refundBtn.titleLabel.font = [UIFont systemFontOfSize:22];
            [refundBtn setTitleColor:[UIColor borderColor] forState:UIControlStateDisabled];
            [self.view addSubview:refundBtn];
            [refundBtn addTarget:self action:@selector(showRefundForm) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //Cancel button
        cancelBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        cancelBtn.frame =   CGRectMake(shipBtn.frame.origin.x + kSpaceBetweenButton, WINDOW_HEIGHT -kBottomSpace, kWidthButton, kHeightButton);
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [self.view addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(showCancelOrder) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    // Show Layout
    [self loadOrderDetailView];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(holdOrderCancelSuccess) name:@"NotifyHoldOrderCancelSuccess" object:nil];
    
}

- (void)assignOrder:(Order *)order
{
    
   // DLog(@"order:%@",order);
    
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
        
//        if(self.order){
//            DLog(@"Order:%@",self.order);
//        }
//        
        if(self.isHoldOrderView){
             self.title = [NSString stringWithFormat:NSLocalizedString(@"Hold Order # %@", nil), [self.order objectForKey:@"increment_id"]];
        }else{
             self.title = [NSString stringWithFormat:NSLocalizedString(@"Order # %@", nil), [self.order objectForKey:@"increment_id"]];
        }
       
    } else {
        
        if(self.isHoldOrderView){
            self.title = NSLocalizedString(@"Hold Order", nil);
        }else{
            self.title = NSLocalizedString(@"Order", nil);
        }
        

        return;
    }
    // Header View
    orderTotal.text = [Price format:[self.order objectForKey:@"grand_total"]];
    
    orderDate.text = [MSDateTime formatDateTime:[self.order objectForKey:@"created_at"]];
    
    orderStatus.text = [[self.order objectForKey:@"status"] capitalizedString];
   // invoiceBtn.hidden = YES;
    
    // Load Order infomation (if need)
    if ([self.order objectForKey:@"items"] == nil) {
        return [self loadOrder];
    }
    
    [self startAnimation];
    
    [self reloadData];
    
    [self stopAnimation];
}

- (void)reloadData
{
    //check Invoice
    if ([self.order canInvoice]) {
        invoiceBtn.enabled=YES;
        invoiceBtn.hidden=NO;
    }else{
        invoiceBtn.enabled=NO;
        invoiceBtn.hidden=YES;
    }
    
    //check Ship
    if ([self.order canShip]) {
        shipBtn.enabled=YES;

    }else{
        shipBtn.enabled=NO;
    }
    
    //check Refund
    if ([self.order canRefund]) {
        refundBtn.enabled =YES;
        refundBtn.hidden =NO;
    }else{
        refundBtn.enabled =NO;
        refundBtn.hidden=YES;
    }
    
    
     if(self.isHoldOrderView){
         cancelBtn.enabled =YES;
         cancelBtn.hidden=NO;
         
     }else{
         //check cancel
         if ([self.order canCancel]) {
             cancelBtn.enabled =YES;
             cancelBtn.hidden=NO;
         }else{
             cancelBtn.enabled =NO;
             cancelBtn.hidden=YES;
         }
     }

    if ([self.order objectForKey:@"status_label"]) {
        orderStatus.text = [self.order objectForKey:@"status_label"];
    }

    totalDue.text = [Price format:[self.order objectForKey:@"total_due"]];
    [self.tableView reloadData];
    
   // [self hideAndShowButtonForHoldOrders];
}

#pragma mark - load order
- (void)loadOrder
{
    
    [self startAnimation];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadOrderThread) object:nil] start];
}

- (void)loadOrderThread
{
    if ([self.order objectForKey:@"customer_name"]) {
        [self.order setValue:[self.order objectForKey:@"customer_name"] forKey:@"org_customer_name"];
    }
    [self.order load:[self.order getIncrementId]];
    
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    [self stopAnimation];
    
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
            if (![MSValidator isEmptyString:[self.order objectForKey:@"webpos_email"]]) {
                detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sold by %@", nil), [self.order objectForKey:@"webpos_email"]];
                detailLabel.hidden = NO;
            }
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sold by %@", nil), [self.order objectForKey:@"webpos_email"]];
            //cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        //chiennd
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    
    DLog(@"QuoteItem>item%@",item);
    
    cell.textLabel.text = [item getName];
    if (item.options) {
        NSString * optionLabel =[item getOptionsLabel];
        NSLog(@"option label :%@",optionLabel);
        cell.detailTextLabel.text =optionLabel;
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
            || [MSValidator isEmptyString:[self.order objectForKey:@"webpos_email"]]
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


#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        return;
    }
    if ([self.order canCancel] && actionSheet.tag == 101) {
        
        [self startAnimation];
        
        [[[NSThread alloc] initWithTarget:self selector:@selector(cancelOrderThread) object:nil] start];
        return;
    }
    
    if ([self.order canShip] && actionSheet.tag == 102) {
        [animation startAnimating];
        //[[[NSThread alloc] initWithTarget:self selector:@selector(cancelOrderThread) object:nil] start];
        return;
    }
    
    
    // Create Invoice for Order
    [self startAnimation];
    [[[NSThread alloc] initWithTarget:self selector:@selector(invoiceOrderThread) object:nil] start];
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

        [self stopAnimation];
    }];
    
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderCreateInvoiceSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [Utilities toastSuccessTitle:@"Invoice" withMessage:MESSAGE_CREATE_SUCCESS withView:self.view];
        
        if ([[self.order objectForKey:@"payment_method"] isEqualToString:@"payanywhere"]) {
          //  [self performSelectorOnMainThread:@selector(showPayAnywhereSDK) withObject:nil waitUntilDone:YES];
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
        [self stopAnimation];
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderCancelSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        invoiceBtn.hidden = YES;
        [cancelBtn setEnabled:NO];

        [self loadOrder];
        
    }];
    [self.order cancel];
    
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

- (void)shipOrderThread
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
        [self stopAnimation];
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderShipSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //[cancelBtn setEnabled:NO];
        //[self loadOrder];
        [self reloadData];
        
    }];
    
    [self.order canShip];
    
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] || [indexPath row] || [MSValidator isEmptyString:[self.order objectForKey:@"customer_id"]]) {
        return;
    }
//    Order *customerOrder = self.order;
//    ViewController *rootViewController = (ViewController *)[(AppDelegate *)[[UIApplication sharedApplication] delegate] revealSideViewController];
//    MenuItem *customerMenu = [rootViewController.menuItems objectAtIndex:3];
//    [customerMenu selectStyle];
//    [rootViewController didSelectMenuItem:customerMenu];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewOrderCustomerDetail" object:customerOrder];
}

#pragma mark - order actions
- (void)printOrderForm
{
    
    UIViewController *print = nil;
        NSNumber * manualPrint = [[NSUserDefaults standardUserDefaults] objectForKey:@"manual_print"];
    
    int typePrint =manualPrint.intValue;
    
    switch (typePrint) {
        case 0:
        {
            print = [StarPrintViewController new];
            // Old Form
            ((StarPrintViewController *)print).order = self.order;
            break;
        }
            
        case 1:
        {
            MagentoPrintViewController *print = [MagentoPrintViewController new];
            print.order = [Order new];
            [print.order setValue:[self.order getIncrementId] forKeyPath:@"increment_id"];
            
            MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
            printNav.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:printNav animated:YES completion:nil];
            return;
        }
            
        case 2:
        {
            print =[[DefaultPrintViewVCViewController alloc] init];
           ((DefaultPrintViewVCViewController *)print).order = self.order;
            break;
        }
                    
        default:
            break;
    }
    

    MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
    printNav.modalPresentationStyle = UIModalPresentationPageSheet;//UIModalPresentationFormSheet;
    [self presentViewController:printNav animated:YES completion:nil];
    printNav.view.superview.frame = CGRectMake(285, 70, 460, 628); // width: 302 ~ 80 mm (1.5)
}

- (void)showEmailForm
{
//    OrderEmailViewController *email = [OrderEmailViewController new];
//    email.order = self.order;
//    MSNavigationController *emailNav = [[MSNavigationController alloc] initWithRootViewController:email];
//    emailNav.modalPresentationStyle = UIModalPresentationPageSheet;
//    [self presentViewController:emailNav animated:YES completion:nil];
//    emailNav.view.superview.frame = CGRectMake(294, 260, 436, 153);

    SendEmailVC * sendEmailVC =[[SendEmailVC alloc] initWithNibName:@"SendEmailVC" bundle:nil];
    sendEmailVC.order =self.order;
    
    UIPopoverController * popOver =[[UIPopoverController alloc] initWithContentViewController:sendEmailVC];
    popOver.popoverContentSize =sendEmailVC.view.frame.size;
    [popOver presentPopoverFromRect:emailBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

-(void)showCancelOrder{
    if ([self.order canCancel]) {
        UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to cancel this order?", nil) delegate:self cancelButtonTitle:@"" destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        confirm.tag = 101;
        [confirm showInView:self.view];
        return;
    }
}


-(void)showShipOrder{

    itemShipVC = [ItemsShipVC new];
    itemShipVC.order = self.order;
    itemShipVC.parrentView =self;
    MSNavigationController *shipNav = [[MSNavigationController alloc] initWithRootViewController:itemShipVC];
    shipNav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:shipNav animated:YES completion:nil];
}

- (void)showRefundForm
{
    refund = [PartialRefundViewController new];
    refund.order = self.order;
    refund.editViewController = self;
    MSNavigationController *refundNav = [[MSNavigationController alloc] initWithRootViewController:refund];
    refundNav.modalPresentationStyle =UIModalPresentationPageSheet;
    [self presentViewController:refundNav animated:YES completion:nil];
}

#pragma mark - note action
- (void)showNoteForm:(id)sender
{
 
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
        shipBtn.hidden =NO;
    }
}

#pragma mark - send to server holder continue
-(void)holdContineOrderProccess{
    
    [self startAnimation];
    
    //[self addDiscountCart];
    
    //[[[NSThread alloc] initWithTarget:self selector:@selector(addDiscountCart) object:nil] start];
    
    [[APIManager shareInstance] holdOrderContinue:[self.order getIncrementId] Callback:^(BOOL success, id result) {
       
         [self stopAnimation];
        
        DLog(@"%@",result);
        
        if(success){

            [[Quote sharedQuote] clearCart];
            
            //Save OrderId in cache
            [self saveOrderIdSession];
            
           // [self addDiscountCart];

            
            [[Quote sharedQuote] loadQuoteItems];
            
            [[Quote sharedQuote] loadQuoteTotals];

            
            NSString * customer_id = [NSString stringWithFormat:@"%@",[self.order objectForKey:@"customer_id"]];
             NSString * customer_name = [NSString stringWithFormat:@"%@",[self.order objectForKey:@"customer_name"]];
             NSString * customer_email = [NSString stringWithFormat:@"%@",[self.order objectForKey:@"customer_email"]];

            
            Customer *customer = [Customer new];
            [customer setObject:customer_id forKey:@"id"];
            [customer setObject:customer_id forKey:@"customer_id"];
            [customer setObject:customer_name forKey:@"name"];
            [customer setObject:customer_email forKey:@"email"];

            [[Quote sharedQuote] assignCustomer:customer];

            
            //B3: Gan gia tri truyen sang Cart de kiem tra va xu ly
            [CartViewController sharedInstance].isHoldOrder =YES;
            [CartViewController sharedInstance].order =self.order;
            
            //B4: Trieu goi man hinh product
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_OPEN_PRODUCT" object:nil];
            
        }
        
    }];
}

#pragma mark - Continue button click
-(void)continueHoldOrderClick{
    //DLog(@"Order info:%@",self.order);

     [self startAnimation];
    
    //B1: Xoa het gio hang o man hinh product
    [[Quote sharedQuote] clearCart];
    
    //B2: Them cac product nay vao gio hang
    NSArray * quotes =[self.order objectForKey:@"items"];
    
    //Save OrderId in cache
    [self saveOrderIdSession];
    
    if(quotes && quotes.count >0){
        
        //Duyet tung product
        for(QuoteItem * quoteItem in quotes){
            
            NSLog(@"quoteItem:%@",quoteItem);
            NSLog(@"quoteItem.product:%@",quoteItem.product);
            
            
           NSString * qty_ordered =[NSString stringWithFormat:@"%@",[quoteItem objectForKey:@"qty_ordered"]];
            
            //add them 1 so thuoc tinh moi
            [quoteItem.product setObject:[quoteItem objectForKey:@"qty_ordered"] forKey:@"qty"];
            
           
            //Dem so luong san pham
            for(int i=0 ; i < qty_ordered.intValue ;i++){
                [[Quote sharedQuote] addProduct:quoteItem.product withOptions:quoteItem.options];
            }
           
        }
    }
    
    //B3: Neu co  discount thi add vao cart
   // [self addDiscountCart];
    
    //B3: Gan gia tri truyen sang Cart de kiem tra va xu ly
    [CartViewController sharedInstance].isHoldOrder =YES;
    [CartViewController sharedInstance].order =self.order;
    
    
    //B4: Trieu goi man hinh product
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_OPEN_PRODUCT" object:nil];
    
    [self stopAnimation];

}



#pragma mark - Cancel button click
-(void)cancelHoldOrderClick{
    DLog(@"CancelClick");

   //[[[NSThread alloc] initWithTarget:animation selector:@selector(startAnimating) object:nil] start];
    

    [self startAnimation];
   
    [self.order cancelHoldOrder];
    
}

#pragma mark - Lang nghe su kien khi cancel thanh cong
-(void)holdOrderCancelSuccess{
    
    [Utilities toastSuccessTitle:@"Order" withMessage:MESSAGE_CANCEL_SUCCESS withView:self.view];

    [self stopAnimation];

}


#pragma mark - save OrderId session for submit to server
-(void)saveOrderIdSession{
    NSString * orderId =[NSString stringWithFormat:@"%@",[self.order objectForKey:@"id"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:orderId forKey:KEY_USERD_DEFAULT_ORDERID];
    [defaults synchronize];
}

-(void)addDiscountCart{
    
    NSDictionary *totals = [self.order objectForKey:@"totals"];
    NSArray * keys =[totals allKeys];
    for(NSString * key in keys){
        
        NSDictionary * total =[totals objectForKey:key];
        if(total && [[total objectForKey:@"code"] isEqualToString:@"discount"]){
            
            Discount *discount = [Discount new];
            NSString * amount = [NSString stringWithFormat:@"%@",[total objectForKey:@"amount"]];
            
            amount =[amount stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSString * title = [NSString stringWithFormat:@"%@",[total objectForKey:@"title"]];
            
            [discount setValue:[NSNumber numberWithFloat:amount.floatValue] forKey:@"amount"];
            [discount setValue:[NSNumber numberWithInteger:0] forKey:@"type"];
            [discount setValue:title forKey:@"description"];
            [discount addCustomDiscount:nil];
            
            return;
        }
        
    }

}

@end
