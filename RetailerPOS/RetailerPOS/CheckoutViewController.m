//
//  CheckoutViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/19/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CheckoutViewController.h"
#import "CatalogViewController.h"
#import "CartViewController.h"
#import "PaymentViewController.h"
#import "ShippingViewController.h"
#import "CreditCardSignViewController.h"
#import "OrderSuccessViewController.h"
#import "Configuration.h"

#import "Price.h"
#import "Quote.h"
#import "Invoice.h"

#import "Paypalhere.h"

@interface CheckoutViewController ()
@property (nonatomic) BOOL needReloadData;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UIView *maskLayer;

- (BOOL)hasCashPayment;
- (void)placeOrderThread;
- (void)stopPlaceOrder;
- (void)clearPaymentForm;
@property (strong, nonatomic) id root;
@end

@implementation CheckoutViewController
@synthesize shipping = _shipping;
@synthesize paymentMethods, paymentMask;
@synthesize headerView, headerLabel, headerTotal;
@synthesize contentView, methodNav, tableView = _tableView;
@synthesize cashButton, orderButton;
@synthesize isCheckoutUpdate;
@synthesize root;

@synthesize maskLayer;
@synthesize collection = _collection;

@synthesize cashInHeader, cashInRemain, cashInValue, cashInView, keyboard;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
	// Add Shipping Method
    self.shipping = [[ShippingViewController alloc] init];
    CGSize shippingSize = [self.shipping reloadContentSize];
    [self addChildViewController:self.shipping];
    [self.view addSubview:self.shipping.view];
    [self.shipping didMoveToParentViewController:self];
    
    // Payment Method & Checkout
    self.paymentMethods = [[UIScrollView alloc] initWithFrame:CGRectMake(49, shippingSize.height + 50, shippingSize.width, 580 - shippingSize.height)];
    self.paymentMethods.backgroundColor = [UIColor lightBorderColor];
    [self.view addSubview:self.paymentMethods];
    
    self.paymentMask = [[UIControl alloc] init];
    [self.paymentMask addTarget:self action:@selector(hidePaymentMask) forControlEvents:UIControlEventTouchUpInside];
    
    // Payment Header Form
    self.headerView = [[UIControl alloc] initWithFrame:CGRectMake(1, 1, 496, 58)];
    self.headerView.backgroundColor = [UIColor barBackgroundColor];//[UIColor backgroundColor];
    [self.paymentMethods addSubview:self.headerView];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 238, 38)];
    [self.headerView addSubview:self.headerLabel];
    self.headerLabel.backgroundColor = self.headerView.backgroundColor;
    self.headerLabel.font = [UIFont systemFontOfSize:24];
    self.headerLabel.text = NSLocalizedString(@"Payment", nil);
    self.headerLabel.textColor = [UIColor whiteColor];
    
    self.headerTotal = [[UILabel alloc] initWithFrame:CGRectMake(248, 10, 238, 38)];
    [self.headerView addSubview:self.headerTotal];
    self.headerTotal.backgroundColor = self.headerView.backgroundColor;
    self.headerTotal.font = [UIFont systemFontOfSize:24];
    self.headerTotal.textAlignment = NSTextAlignmentRight;
    self.headerTotal.text = [Price format:[[Quote sharedQuote] getGrandTotal]];
    self.headerTotal.textColor = [UIColor whiteColor];//[UIColor buttonPressedColor];
    
    // Payment Content Form
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(1, 60, 496, 519 - shippingSize.height)];
    [self.paymentMethods addSubview:self.contentView];
    
    // Cash In
    cashInHeader = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, 498, 1)];
    cashInHeader.backgroundColor = self.headerView.backgroundColor;
    cashInHeader.layer.borderColor = self.paymentMethods.backgroundColor.CGColor;
    cashInHeader.layer.borderWidth = 1.0;
    [self.contentView addSubview:cashInHeader];
    
    UIView *cashSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 498, 1)];
    cashSeparator.backgroundColor = self.paymentMethods.backgroundColor;
    [cashInHeader addSubview:cashSeparator];
    
    cashInValue = [[UITextField alloc] initWithFrame:CGRectMake(11, 5, 476, 30)];
    cashInValue.textAlignment = NSTextAlignmentRight;
    cashInValue.font = [UIFont systemFontOfSize:24];
    cashInValue.text = @"";
    [cashInHeader addSubview:cashInValue];
    
    cashInRemain = [cashInValue clone];
    cashInRemain.frame = CGRectMake(11, 45, 476, 30);
    [cashInHeader addSubview:cashInRemain];
    cashInValue.delegate = self;
    cashInRemain.delegate = self;
    
    cashInView = [UIView new];
    cashInView.backgroundColor = self.headerView.backgroundColor;
    // Setup Keyboard for Cash
    keyboard = [[MSNumberPad alloc] init];
    [keyboard resetConfig];
    keyboard.delegate = self;
    keyboard.doneLabel = @"00";
    keyboard.maxInput = 13;
    keyboard.currentValue = 0;
    keyboard.floatPoints = [Price precision];
    keyboard.isShowExtButton = YES;
    keyboard.textField = cashInValue;
    
    // Select Payment method
    self.collection = [Quote sharedQuote].payment.collection;
    PaymentViewController *payment = [[PaymentViewController alloc] init];
    payment.checkout = self;
    self.methodNav = [[MSNavigationController alloc] initWithRootViewController:payment];
    self.methodNav.delegate = self;
    [self.methodNav setNavigationBarHidden:YES];
    self.methodNav.view.frame = CGRectMake(0, cashInHeader.frame.size.height - 1, 496, 519 - shippingSize.height - cashInHeader.frame.size.height);
    [self addChildViewController:self.methodNav];
    [self.contentView addSubview:self.methodNav.view];
    [self.methodNav didMoveToParentViewController:self];
    
    self.tableView = payment.tableView;
    
    // Payment Animation & Event
    self.animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.animation.frame = CGRectZero;
    self.animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [self.paymentMethods addSubview:self.animation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePaymentMethods) name:@"CollectionPaymentLoadAfter" object:nil];
    
    // Bottom & Checkout Button
//    self.cashButton = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
//    self.cashButton.frame = CGRectMake(49, 660, 238, 65);
//    [self.view addSubview:self.cashButton];
//    self.cashButton.titleLabel.font = [UIFont systemFontOfSize:24];
//    [self.cashButton setTitle:NSLocalizedString(@"Cash In", nil) forState:UIControlStateNormal];
//    [self.cashButton addTarget:self action:@selector(tapCashInButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.orderButton = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
   
    //self.orderButton.frame = CGRectMake(307, 660, 238, 65);
    self.orderButton.frame = CGRectMake(200, 660, 238, 65);
    
    [self.view addSubview:self.orderButton];
    [self.orderButton addTarget:self action:@selector(placeOrderAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self reloadButtonStatus];
    self.orderButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.orderButton setTitle:NSLocalizedString(@"Place Order", nil) forState:UIControlStateNormal];
    
    self.needReloadData = YES;
    self.isCheckoutUpdate = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quoteUpdateComplete) name:QuoteEndRequestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"GoToCheckoutPage" object:nil];

    
    [self reloadData];
    
    UIView * verticalLine =[[UIView alloc] init];
    verticalLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    verticalLine.frame =CGRectMake(0, 0, 1, CGRectGetHeight(self.view.frame));
    [self.view addSubview:verticalLine];
}

#pragma mark - cash in methods
- (void)tapCashInButton
{
    if (self.shipping.isShowContent) {
        [self hidePaymentMask];
    }
    if (cashInView.superview) {
        if ([Quote sharedQuote].cashIn < 0.0001) {
            [Quote sharedQuote].cashIn = 0.0;
            cashInHeader.frame = CGRectMake(-1, -1, 498, 1);
        } else {
            cashInHeader.frame = CGRectMake(-1, -1, 498, 80);
        }
        [cashInView removeFromSuperview];
        [self reloadPaymentFormSize];
        [self.cashButton setTitle:NSLocalizedString(@"Cash In", nil) forState:UIControlStateNormal];
        return;
    }
    cashInHeader.frame = CGRectMake(-1, -1, 498, 80);
    [self reloadPaymentFormSize];
    [self.contentView addSubview:cashInView];
    cashInView.frame = self.methodNav.view.frame;
    
    [keyboard showOn:self atFrame:CGRectMake(10, cashInView.frame.size.height / 2 - 165, 476, 330)]; // button: 60
    [cashInView addSubview:keyboard.view];
    
    keyboard.currentValue = [Quote sharedQuote].cashIn;
    cashInValue.text = [self numberPadFormatOutput:keyboard];
    [self.cashButton setTitle:NSLocalizedString(@"Payment Methods", nil) forState:UIControlStateNormal];
}

- (long double)externalValue:(NSUInteger)tag
{
    long double total = [[[Quote sharedQuote] getGrandTotal] doubleValue];
    if (tag == 22) {
        return total;
    }
    long double mod = 5;
    if (total > 100) {
        NSUInteger numberDigit = 0;
        long double tempTotal = floorl(total / 100);
        while (tempTotal > 0.1) {
            numberDigit++;
            tempTotal = floorl(tempTotal / 10);
        }
        mod = 5 * powl(10, numberDigit);
    }
    if (tag == 21) {
        return floorl(total / mod) * mod;
    } else {
        return ceil(total / mod) * mod;
    }
}

#pragma mark - number pad delegate
- (void)numberPad:(MSNumberPad *)numberPad didChangeValue:(NSInteger)value
{
    if (value > 20) {
        numberPad.currentValue = [self externalValue:value];
        [numberPad updateInputTextField];
    }
}

- (void)numberPad:(MSNumberPad *)numberPad willShowButton:(UIButton *)button
{
    if (button.tag == 13) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    }
    if (button.tag > 20) {
        [button setTitle:[Price format:[NSNumber numberWithDouble:[self externalValue:button.tag]]] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:24];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button.titleLabel setMinimumScaleFactor:0.5];
    }
}

- (BOOL)numberPadShouldDone:(MSNumberPad *)numberPad
{
    UIButton *zeroButton = (UIButton *)[numberPad.view viewWithTag:0];
    [numberPad numberButtonTapped:zeroButton];
    [numberPad numberButtonTapped:zeroButton];
    return NO;
}

- (NSString *)numberPadFormatOutput:(MSNumberPad *)numberPad
{
    [Quote sharedQuote].cashIn = numberPad.currentValue;
    // Update for Remain
    NSNumber *remain = [NSNumber numberWithDouble:([[[Quote sharedQuote] getGrandTotal] doubleValue] - numberPad.currentValue)];
    cashInRemain.text = [NSString stringWithFormat:NSLocalizedString(@"Remain:   %@", nil), [Price format:remain]];
    if (remain.doubleValue < 0.0001 && !self.orderButton.isEnabled && [self hasCashPayment]) {
        [self.orderButton setEnabled:YES];
    } else if (remain.doubleValue >= 0.0001 && self.orderButton.isEnabled && [self hasCashPayment]) {
        [self reloadButtonStatus];
    }
    // Return current cash in
    return [NSString stringWithFormat:NSLocalizedString(@"Cash In:   %@", nil), [Price format:[NSNumber numberWithDouble:numberPad.currentValue]]];
}

- (BOOL)hasCashPayment
{
    for (NSUInteger i = 0; i < [self.collection getSize]; i++) {
        Payment *method = [self.collection objectAtIndex:i];
//        if ([[method getId] isEqualToString:@"checkmo"]
//            || [[method getId] isEqualToString:@"cashondelivery"]
//        ) {
        if ([[method getId] isEqualToString:@"cashin"]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (cashInView.superview == nil) {
        [self tapCashInButton];
    }
    return NO;
}

#pragma mark - reload payment form size
- (void)reloadPaymentFormSize
{
    CGSize shippingSize = [self.shipping reloadContentSize];
    self.paymentMethods.frame = CGRectMake(49, shippingSize.height + 50, shippingSize.width, 580 - shippingSize.height);
    self.contentView.frame = CGRectMake(1, 60, 496, 519 - shippingSize.height);
    self.methodNav.view.frame = CGRectMake(0, cashInHeader.frame.size.height - 1, 496, 519 - shippingSize.height - cashInHeader.frame.size.height);
    if (self.shipping.isShowContent) {
        self.paymentMask.frame = self.paymentMethods.bounds;
        [self.paymentMethods addSubview:self.paymentMask];
    } else {
        [self.paymentMask removeFromSuperview];
    }
}

- (IBAction)hidePaymentMask
{
    [self.shipping toggleShippingForm];
}

- (void)quoteUpdateComplete
{
    if (self.isCheckoutUpdate) {
        self.isCheckoutUpdate = NO;
    } else {
        // Check shipping is showing, reload it now
        if (self.view.frame.origin.x < 1000) {
            // Reload shipping methods
            //[self.shipping reloadData];
        } else {
            self.needReloadData = YES;
        }
    }
    // Check View and Reload Payment Label
    self.headerTotal.text = [Price format:[[Quote sharedQuote] getGrandTotal]];
    if ([Quote sharedQuote].cashIn > 0.0001) {
        [keyboard updateInputTextField];
    }
}

#pragma mark - load data from server
- (void)reloadData
{
    if (!self.needReloadData) {
        return;
    }
    self.needReloadData = NO;
    // Reload shipping
   // [self.shipping reloadData];
    
    // Reload Payment Methods
    self.animation.frame = self.paymentMethods.bounds;
    [self.animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadPaymentDataThread) object:nil] start];
    
    // Reload Cash IN form
    [self reloadButtonStatus];
    if (cashInView.superview) {
        [keyboard showOn:self atFrame:CGRectMake(10, cashInView.frame.size.height / 2 - 165, 476, 330)]; // button: 60
        [cashInView addSubview:keyboard.view];
        
        keyboard.currentValue = [Quote sharedQuote].cashIn;
        cashInValue.text = [self numberPadFormatOutput:keyboard];
    }
}

- (void)loadPaymentDataThread
{
    //[self.collection clear];
    //[self.collection load];
    
    // Stop animation
    self.animation.frame = CGRectZero;
    [self.animation stopAnimating];
}

- (void)updatePaymentMethods
{
    [self.tableView reloadData];
}

#pragma mark - update buttons
- (void)reloadButtonStatus
{
   // [self.orderButton setEnabled:[[Quote sharedQuote].payment validate]];
}

#pragma mark - button actions
- (void)placeOrderAction
{
    [self stopPlaceOrder];
    [self showOrderSuccessForm];

   // [self placeOrderMain];
}

- (void)placeOrderMain
{
    CatalogViewController *viewController = (CatalogViewController *)self.parentViewController;
    if (maskLayer == nil) {
        maskLayer = [[UIView alloc] initWithFrame:viewController.view.bounds];
        // Animation for mask layer
        UIActivityIndicatorView *submitingOrder = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        submitingOrder.frame = self.view.frame;
        submitingOrder.tag = 1;
        submitingOrder.color = [UIColor grayColor];
        submitingOrder.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [maskLayer addSubview:submitingOrder];
    }
    
    // Hide back button, add mask layer, start animation
    [viewController.view addSubview:maskLayer];
    [(UIActivityIndicatorView *)[maskLayer viewWithTag:1] startAnimating];
    for (MSNavigationController *navControl in viewController.childViewControllers) {
        if ([navControl isKindOfClass:[MSNavigationController class]]
            && [navControl.topViewController isKindOfClass:[CartViewController class]]
        ) {
            navControl.topViewController.navigationItem.leftBarButtonItem = nil;
        }
    }
    if (![[Quote sharedQuote].payment validate]
        || [[[Quote sharedQuote] getGrandTotal] doubleValue] <= [Quote sharedQuote].cashIn
    ) {
        // Select Cash In Payment
        for (NSUInteger i = 0; i < [self.collection getSize]; i++) {
            Payment *method = [self.collection objectAtIndex:i];
//            if ([[method getId] isEqualToString:@"checkmo"]
//                || [[method getId] isEqualToString:@"cashondelivery"]
//                ) {
            if ([[method getId] isEqualToString:@"cashin"]) {
                [self.methodNav popToRootViewControllerAnimated:NO];
                UITableView *tableView = [(PaymentViewController *)self.methodNav.topViewController tableView];
                // Update Payment Method
                Payment *payment = [Quote sharedQuote].payment;
                if (![payment isCurrentMethod:method]) {
                    [payment setValue:[method getId] forKey:@"method"];
                    for (NSUInteger j = 0; j < [self.collection getSize]; j++) {
                        if ([payment.instance isEqual:[self.collection objectAtIndex:j]]) {
                            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:j inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            break;
                        }
                    }
                    payment.instance = method;
                    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                break;
            }
        }
    }
    // Place Order on new Thread
    [[[NSThread alloc] initWithTarget:self selector:@selector(placeOrderThread) object:nil] start];
}


- (void)transactionResults:(id)response
{
    Invoice *invoice = [Invoice new];
    [invoice setValue:[[Quote sharedQuote].order objectForKey:@"invoice"] forKey:@"increment_id"];
    if ([[response objectForKey:@"Transaction status"] isEqualToString:@"Approved"]) {
        // Transaction Success > Capture Invoice
        [invoice capture];
    } else {
        // Transaction canceled or fail > Cancel Invoice
        [invoice cancel];
        // Remove invoice id from quote order
        [[Quote sharedQuote].order removeObjectForKey:@"invoice"];
    }
    // Reload Order
    Order *order = [Order new];
    [order load:[[Quote sharedQuote].order getId]];
    [[Quote sharedQuote].order setValue:order forKey:@"loaded_order"];
    // Update order status
    if ([order objectForKey:@"status"]) {
        [[Quote sharedQuote].order setValue:[order objectForKey:@"status"] forKey:@"status"];
    }
    if ([order objectForKey:@"status_label"]) {
        [[Quote sharedQuote].order setValue:[order objectForKey:@"status_label"] forKey:@"status_label"];
    }
    // Reload form
    [self stopPlaceOrder];
    [self showOrderSuccessForm];
    if (![[[UIApplication sharedApplication].keyWindow subviews] count]) {
        [[UIApplication sharedApplication].keyWindow addSubview:[(UIViewController *)root view]];
    }
}

- (void)placeOrderThread
{
    // request to server failt
    id requestFailt = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        
        [self stopPlaceOrder];
        
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
   
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    
    // Process After set payment success
    id requestPaymentSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"PaymentSaveMethodAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Place order success, Show Signature Form
        id placeOrderSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"QuotePlaceOrderSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self stopPlaceOrder];
            
            [self showOrderSuccessForm];
            
        }];
        
        NSMutableDictionary *config = [NSMutableDictionary new];
        if ([[Quote sharedQuote].payment.instance isCreditCardMethod]) {
            // create invoice for credit card payment method
            [config setValue:[Quote sharedQuote].payment forKey:@"payment"];
            [config setValue:[NSNumber numberWithBool:YES] forKey:@"is_invoice"];
        } else if ([[Quote sharedQuote].payment.instance hasOptionForm]) {
            if ([[Quote sharedQuote].payment objectForKey:@"is_invoice"]) {
                [config setValue:[[Quote sharedQuote].payment objectForKey:@"is_invoice"] forKey:@"is_invoice"];
            }
        } else if ([[[Quote sharedQuote].payment.instance getId] isEqualToString:@"payanywhere"]
            || [[[Quote sharedQuote].payment objectForKey:@"method"] isEqualToString:@"paypalhere"]
        ) {
            [config setValue:[NSNumber numberWithBool:YES] forKey:@"is_invoice"];
        }
        [config setValue:[NSNumber numberWithBool:[Quote sharedQuote].isShipped] forKey:@"is_shipped"];
        // Cash In
        if ([Quote sharedQuote].cashIn > 0.0001) {
            [config setValue:[NSNumber numberWithDouble:[Quote sharedQuote].cashIn] forKey:@"cash_in"];
        }
        
        // Place order
        [[Quote sharedQuote] placeOrder:config];
        
        // clear form after place order
        if (![[[Quote sharedQuote].payment.instance getId] isEqualToString:@"payanywhere"]) {
            [self stopPlaceOrder];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:placeOrderSuccess];
    }];
    
    Payment *payment = [Quote sharedQuote].payment;
    [payment saveMethod];
    
    CFTimeInterval endTime = CACurrentMediaTime() + 2;
    while (CACurrentMediaTime() < endTime) {
        // Wait 2 second
    }
    if (![[payment.instance getId] isEqualToString:@"payanywhere"]) {
        [self stopPlaceOrder];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:requestFailt];
    [[NSNotificationCenter defaultCenter] removeObserver:requestPaymentSuccess];
}

- (void)stopPlaceOrder
{
   // if ([Quote sharedQuote].order == nil) {
        for (MSNavigationController *navControl in self.parentViewController.childViewControllers) {
            if ([navControl isKindOfClass:[MSNavigationController class]]
                && [navControl.topViewController isKindOfClass:[CartViewController class]]
                ) {
                [(CartViewController *)navControl.topViewController showBackButton];
            }
        }
    //}
    [(UIActivityIndicatorView *)[maskLayer viewWithTag:1] stopAnimating];
    [maskLayer removeFromSuperview];
    
}


- (void)showOrderSuccessForm
{
    // Clear all payment info of last order
    [self performSelectorOnMainThread:@selector(clearPaymentForm) withObject:nil waitUntilDone:NO];
    
    // After place order success, Show this Form to send email or print invoice
    OrderSuccessViewController *successController = [OrderSuccessViewController new];
    successController.view.frame = self.view.bounds;
    
    [successController setGrandTotalPrice:self.headerTotal.text];
    
    [self addChildViewController:successController];
    [self.view addSubview:successController.view];
    [successController didMoveToParentViewController:self];
    
    // Add comment for order
    [[Quote sharedQuote].order comment:[[Quote sharedQuote] objectForKey:@"order_comment"]];
    [[Quote sharedQuote] removeObjectForKey:@"order_comment"];
}

- (void)clearPaymentForm
{
    [self.methodNav popToRootViewControllerAnimated:NO];
    [self.methodNav setNavigationBarHidden:YES];
    
    // Hide Cash In Form
    cashInHeader.frame = CGRectMake(-1, -1, 498, 1);
    if (cashInView) {
        [cashInView removeFromSuperview];
    }
    
    //An nut back o CartView
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NofityHideBackButtonWhenOrderSuccess" object:nil];
}

@end
