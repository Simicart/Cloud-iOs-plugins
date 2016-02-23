//
//  SimiPayPalWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiPayPalWorker.h"
#import "SimiOrderModel+PayPal.h"
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCThankyouPageViewController.h>
#define ALERT_VIEW_ERROR 0

@implementation SimiPayPalWorker{
    SimiModel *payment;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiOrderModel *order;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    payment = [noti.userInfo valueForKey:@"payment"];
    if ([[payment valueForKey:@"method_code"] isEqualToString:@"paypal"]) {
        if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {
            payPalAppKey = [payment valueForKey:@"client_id"];
            payPalReceiverEmail = [payment valueForKey:@"paypal_email"];
            BOOL isSandbox = [[payment valueForKey:@"sandbox"] boolValue];
            @try {
                if (isSandbox) {
                    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox : payPalAppKey}];
                    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
                }else{
                    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : payPalAppKey}];
                    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alertView.tag = ALERT_VIEW_ERROR;
                [alertView show];
            }
            @finally {
                
            }
        }else if ([noti.name isEqualToString:DidPlaceOrderAfter]){
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti{
    viewController = [noti.userInfo valueForKey:@"controller"];
    if (!viewController) {
        UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        viewController = [navi.viewControllers lastObject];
        
    }
    viewController.isDiscontinue = YES;
    order = [noti.userInfo valueForKey:@"data"];
    
    payPalAppKey = [payment valueForKey:@"client_id"];
    payPalReceiverEmail = [payment valueForKey:@"paypal_email"];
    bnCode = [payment valueForKey:@"bncode"];
    
    BOOL isSandbox = [[payment valueForKey:@"sandbox"] boolValue];
    @try {
        if (isSandbox) {
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
        }else{
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
        }
        
        PayPalConfiguration *_payPalConfig = [[PayPalConfiguration alloc] init];
        _payPalConfig.acceptCreditCards = YES;
        _payPalConfig.languageOrLocale = LOCALE_IDENTIFIER;
        
        PayPalPayment *pay = [[PayPalPayment alloc] init];
        pay.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.2f", [[order valueForKey:@"grand_total"] floatValue]]];
        pay.currencyCode = CURRENCY_CODE;
        pay.bnCode = bnCode;
        pay.shortDescription = [NSString stringWithFormat:@"%@ #: %@", SCLocalizedString(@"Invoice"), [order valueForKey:@"seq_no"]];
        pay.intent = PayPalPaymentIntentSale;
        if ([[payment valueForKey:@"payment_action"] isEqualToString:@"1"]) {
            pay.intent = PayPalPaymentIntentAuthorize;
        }else if([[payment valueForKey:@"payment_action"] isEqualToString:@"2"])
        {
            pay.intent = PayPalPaymentIntentOrder;
        }
        // Check whether payment is processable.
        if (pay.processable) {
            PayPalPaymentViewController *paymentViewController;
            paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:pay configuration:_payPalConfig delegate:self];
            
            // Present the PayPalPaymentViewController.
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:0 green:69/255.0 blue:124/255.0 alpha:1]];
            }
            [viewController startLoadingData];
            [viewController presentViewController:paymentViewController animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_ERROR;
            [alertView show];
            [viewController stopLoadingData];
            [viewController.navigationController popViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, PayPal is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
        [viewController stopLoadingData];
        [viewController.navigationController popViewControllerAnimated:YES];
    }
    @finally {
        
    }
}

- (void)didUpdatePaymentStatus:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    order = noti.object;
    [viewController stopLoadingData];
    UIAlertView *alertView;
    if([[order valueForKey:@"status"] isEqualToString:@"errors"]){
        alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Sorry!") message:@"Have some errors, please try again." delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    else{
        //delete current quote
        [[SimiGlobalVar sharedInstance] setQuoteId:nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults valueForKey:@"quoteId"]) {
            [userDefaults setValue:@"" forKey:@"quoteId"];
            [userDefaults synchronize];
        }
        
        if (SIMI_SYSTEM_IOS >= 8) {
            [viewController.navigationController popToRootViewControllerAnimated:YES];
        }else
        {
            [viewController.navigationController popToRootViewControllerAnimated:NO];
        }
        if([[order valueForKey:@"status"] isEqualToString:@"pending"] || [[order valueForKey:@"status"] isEqualToString:@"paid"]){
            if(!((SCOrderViewController*)viewController).isNewCustomer){
                SCThankYouPageViewController *thankVC = [[SCThankYouPageViewController alloc] init];
                thankVC.number = [order valueForKey:@"seq_no"];
                thankVC.order = order;
                if(((SCOrderViewController*)viewController).checkoutGuest){
                    thankVC.isGuest = YES;
                }else
                    thankVC.isGuest = NO;
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [(UINavigationController *)currentVC pushViewController:thankVC animated:YES];
                }else{
                    UINavigationController *navi;
                    navi = [[UINavigationController alloc]initWithRootViewController:thankVC];
                    UIPopoverController* popThankController = [[UIPopoverController alloc] initWithContentViewController:navi];
                    thankVC.popOver = popThankController;
                    [popThankController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
                }
            }
        }else if([[order valueForKey:@"status"] isEqualToString:@"cancelled"]){
            alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"") message:@"Your payment is cancelled." delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
        }
        else{
        
        }
    }
    [self removeObserverForNotification:noti];
}

#pragma mark PayPalPaymentDelegate methods
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"PayPal Payment Success!");
    }
    // Payment was processed successfully; send to server for verification and fulfillment
    [paymentViewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [self sendCompletedPaymentToServer:completedPayment];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"PayPal Payment Canceled");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:DidUpdatePaymentStatus object:order];
    [paymentViewController dismissViewControllerAnimated:YES completion:^{
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }];
    [viewController startLoadingData];
    [order updateOrderWithPaymentStatus:PaymentStatusCancelled proof:nil];
}

#pragma mark Proof of payment validation
- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePaymentStatus:) name:DidUpdatePaymentStatus object:order];
    NSLog(@"%@",[viewController.navigationController viewControllers]);
//    [viewController dismissViewControllerAnimated:YES completion:^{
//        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    }];
    [viewController startLoadingData];
    [order updateOrderWithPaymentStatus:PaymentStatusApproved proof:completedPayment.confirmation];
}

#pragma mark Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ALERT_VIEW_ERROR) {
        [self payPalPaymentDidCancel:nil];
    }
}

@end
