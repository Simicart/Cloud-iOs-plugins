//
//  OrderSuccessViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2016/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "OrderSuccessViewController.h"
#import "CartViewController.h"
#import "Quote.h"
#import "Price.h"
#import "MSFramework.h"
#import "OrderPrintViewController.h"
#import "MagentoPrintViewController.h"
#import "StarPrintViewController.h"
#import "Configuration.h"

#import "DefaultPrintViewVCViewController.h"

@interface OrderSuccessViewController ()
@property (strong, nonatomic) MSTextField *emailAddress;
@property (strong, nonatomic) UIButton *sendButton;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
@end

@implementation OrderSuccessViewController
{
    UILabel *totalLabel;
}
@synthesize emailAddress, sendButton, animation = _animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    
    // Success Information
    totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 36, 400, 48)];
    //totalLabel.text =[NSString stringWithFormat:@"%@",grandTotalPrice]; //[Price format:[[Quote sharedQuote] getGrandTotal]];
    totalLabel.textColor = [UIColor buttonPressedColor];
    totalLabel.font = [UIFont boldSystemFontOfSize:44];
    totalLabel.textAlignment = NSTextAlignmentCenter;
    totalLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:totalLabel];
    
    UIImageView *orderSuccessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
    orderSuccessImage.frame = CGRectMake(84, 116, 50, 50);
    [self.view addSubview:orderSuccessImage];
    
    UILabel *orderSuccessLabel = [[UILabel alloc] initWithFrame:CGRectMake(148, 100, 396, 50)];
    orderSuccessLabel.text = NSLocalizedString(@"Order has been created successfully", nil);
    orderSuccessLabel.font = [UIFont systemFontOfSize:20];
    orderSuccessLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:orderSuccessLabel];
    
    
    //Payment Method
    if([Quote sharedQuote].mrPayment){
        UILabel *paymentMethodLabel = [[UILabel alloc] initWithFrame:CGRectMake(148, 148, 396, 24)];
        paymentMethodLabel.text = [NSString stringWithFormat:@"%@", [Quote sharedQuote].mrPayment.title];
        paymentMethodLabel.font = [UIFont systemFontOfSize:20];
        paymentMethodLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:paymentMethodLabel];
    }
        
    if([Quote sharedQuote].isShipped && [Quote sharedQuote].mrShipping){
        //Shipping Method
        UILabel *shipMethodLabel = [[UILabel alloc] initWithFrame:CGRectMake(148, 188, 396, 24)];
        NSString * priceShip = [Price format:[Quote sharedQuote].mrShipping.price];
        
        shipMethodLabel.text = [NSString stringWithFormat:@"%@ (%@)", [Quote sharedQuote].mrShipping.name,priceShip];
        shipMethodLabel.font = [UIFont systemFontOfSize:20];
        shipMethodLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:shipMethodLabel];
    }
    
    
    UILabel *invoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 230, 396, 24)];
    invoiceLabel.font = [UIFont systemFontOfSize:20];
    invoiceLabel.textAlignment = NSTextAlignmentCenter;
    invoiceLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:invoiceLabel];
    if ([[Quote sharedQuote].order objectForKey:@"invoice"]) {
        if ([[[Quote sharedQuote].order objectForKey:@"status"] isEqualToString:@"complete"]) {
            invoiceLabel.text = NSLocalizedString(@"Order fulfillment", nil);
        } else {
            invoiceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Order is %@", nil), [[Quote sharedQuote].order objectForKey:@"status_label"]];
        }
        invoiceLabel.textColor = [UIColor colorWithRed:0.15 green:0.6 blue:0.16 alpha:1];
        
        UILabel *invoiceIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 236, 396, 24)];
        invoiceIdLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Invoice ID: #%@", nil), [[Quote sharedQuote].order objectForKey:@"invoice"]];
        invoiceIdLabel.textColor = invoiceLabel.textColor;
        invoiceIdLabel.font = [UIFont systemFontOfSize:20];
        invoiceIdLabel.textAlignment = NSTextAlignmentCenter;
        invoiceIdLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:invoiceIdLabel];
    } else {
        invoiceLabel.text = NSLocalizedString(@"Order is pending payment", nil);
        invoiceLabel.textColor = [UIColor orangeColor];
    }
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 300, 596, 1)];
    separator.backgroundColor = [UIColor grayColor];
    [self.view addSubview:separator];
    
    // After place order action
    emailAddress = [[MSTextField alloc] initWithFrame:CGRectMake(48, 348, 500, 54)];
    emailAddress.placeholder = NSLocalizedString(@"Email Address", nil);
    emailAddress.textPadding = UIEdgeInsetsMake(15, 10, 15, 10);
    emailAddress.font = [UIFont systemFontOfSize:20];
    emailAddress.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    emailAddress.keyboardType = UIKeyboardTypeEmailAddress;
    emailAddress.returnKeyType = UIReturnKeySend;
    [emailAddress.layer setBorderWidth:1.0];
    [emailAddress.layer setBorderColor:[UIColor colorWithWhite:0.88 alpha:1].CGColor];
    [self.view addSubview:emailAddress];
    emailAddress.delegate = self;
    [emailAddress addTarget:self action:@selector(changeEmailAddress) forControlEvents:UIControlEventEditingChanged];
    [emailAddress addTarget:self action:@selector(doneEditEmailAddress) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    sendButton = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(457, 351, 88, 48);
    [self.view addSubview:sendButton];
    [sendButton addTarget:self action:@selector(sendEmailReceipt) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *customerEmail = [[Quote sharedQuote] objectForKey:@"customer_email"];
    if ([[Quote sharedQuote] hasCustomer] && customerEmail && [MSValidator validateEmail:customerEmail]) {
        emailAddress.text = customerEmail;
    } else {
        [sendButton setEnabled:NO];
    }
    
    UIButton *printButton = [MSGrayButton buttonWithType:UIButtonTypeCustom];
    printButton.frame = CGRectMake(48, 422, 500, 54);
    printButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [printButton setTitle:NSLocalizedString(@"Print Receipt", nil) forState:UIControlStateNormal];
//    [printButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [printButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.88 alpha:1]] forState:UIControlStateNormal];
//    [printButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [printButton setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
    [self.view addSubview:printButton];
    [printButton addTarget:self action:@selector(printReceipt) forControlEvents:UIControlEventTouchUpInside];
    
    // Start new order
    UIButton *newOrderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
//    [newOrderButton setBackgroundImage:[[UIImage imageNamed:@"btn_checkout.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
//    [newOrderButton setBackgroundImage:[[UIImage imageNamed:@"btn_checkout_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
//   
    
    newOrderButton.backgroundColor = [UIColor barBackgroundColor];

    [newOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [newOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    newOrderButton.frame = CGRectMake(148, 660, 300, 65);
    newOrderButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [newOrderButton setTitle:NSLocalizedString(@"Start New Order", nil) forState:UIControlStateNormal];
    newOrderButton.layer.cornerRadius =5.0;
    
    [self.view addSubview:newOrderButton];
    [newOrderButton addTarget:self action:@selector(startNewOrder) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIActivityIndicatorView *)getAnimation
{
    if (self.animation == nil) {
        self.animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.view addSubview:self.animation];
    }
    return self.animation;
}

#pragma mark - send email
- (void)changeEmailAddress
{
    [sendButton setEnabled:[MSValidator validateEmail:emailAddress.text]];
}

- (void)doneEditEmailAddress
{
    if ([MSValidator validateEmail:emailAddress.text]) {
        [self sendEmailReceipt];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([MSValidator validateEmail:textField.text]) {
        return YES;
    }
    return NO;
}

- (void)sendEmailReceipt
{
    [self getAnimation].frame = emailAddress.frame;
    [[self getAnimation] startAnimating];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(sendEmailReceiptThread) object:nil] start];
}

- (void)sendEmailReceiptThread
{
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderSendEmailSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [Utilities alert:NSLocalizedString(@"Success", nil) withMessage:NSLocalizedString(@"The order email has been sent.", nil)];
    }];
    [[Quote sharedQuote].order sendEmail:emailAddress.text];
    
    [[NSNotificationCenter defaultCenter] removeObserver:success];
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[self getAnimation] stopAnimating];
}

#pragma mark - print and new order
- (void)printReceipt
{
    /*
    if ([[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue] == 1) {
        MagentoPrintViewController *print = [MagentoPrintViewController new];
        print.order = [Order new];
        [print.order setValue:[[Quote sharedQuote].order getId] forKey:@"increment_id"];
        
        MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
        printNav.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:printNav animated:YES completion:nil];
        return;
    }

    OrderPrintViewController *print = [OrderPrintViewController new];
    // Old form
    if ([[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue] == 0) {
        print = (OrderPrintViewController *)[StarPrintViewController new];
    }
    if ([[Quote sharedQuote].order objectForKey:@"loaded_order"]) {
        print.order = [[Quote sharedQuote].order objectForKey:@"loaded_order"];
    } else {
        print.order = [Order new];
        [print.order setValue:[[Quote sharedQuote].order getId] forKey:@"increment_id"];
        [[Quote sharedQuote].order setValue:print.order forKey:@"loaded_order"];
    }
    MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
    printNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:printNav animated:YES completion:nil];
    printNav.view.superview.frame = CGRectMake(285, 70, 454, 628);
     
     */
    
    
    
    UIViewController *print = nil;
    NSNumber * manualPrint = [[NSUserDefaults standardUserDefaults] objectForKey:@"manual_print"];
    
    Order *order = [Order new];
    [order setValue:[[Quote sharedQuote].order getId] forKeyPath:@"increment_id"];
    
    int typePrint =manualPrint.intValue;
    
    typePrint =0;
    
    switch (typePrint) {
        case 0:
        {
            print = [StarPrintViewController new];
            ((StarPrintViewController *)print).order = order;
            break;
        }
            
        case 1:
        {
            print = [MagentoPrintViewController new];
            ((MagentoPrintViewController *)print).order = order;
            break;
        }
            
        case 2:
        {
           print =[DefaultPrintViewVCViewController new];
            ((DefaultPrintViewVCViewController*)print).order = order;
            break;
        }
            
        default:
        {
            print =[DefaultPrintViewVCViewController new];
            ((DefaultPrintViewVCViewController*)print).order = order;
            break;
        }
    }
    
    
    MSNavigationController *printNav = [[MSNavigationController alloc] initWithRootViewController:print];
    printNav.modalPresentationStyle = UIModalPresentationPageSheet;//UIModalPresentationFormSheet;
    [self presentViewController:printNav animated:YES completion:nil];
    printNav.view.superview.frame = CGRectMake(285, 70, 500, 628); // width: 302 ~ 80 mm (1.5)
    
}

- (void)startNewOrder
{
    // Clear current quote
    [[Quote sharedQuote] cleanData];
    // Back to product page
    for (MSNavigationController *navControl in self.parentViewController.parentViewController.childViewControllers) {
        if ([navControl isKindOfClass:[MSNavigationController class]]
            && [navControl.topViewController isKindOfClass:[CartViewController class]]
        ) {
            [(CartViewController *)navControl.topViewController backToShoppingCart];
        }
    }
    // Reload view
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteEndRequestNotification object:[Quote sharedQuote] userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:[Quote sharedQuote] userInfo:nil];
    // Remove success controller
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - setGrandTotalPrice
-(void)setGrandTotalPrice:(NSString *)totalPrice{
    totalLabel.text = totalPrice;
}
@end
