//
//  SimiPayUIndianWorker.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 2/1/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUIndianWorker.h"
#import "SimiPayUIndianModel.h"
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>

@implementation SimiPayUIndianWorker {
    SimiOrderModel *order;
    SimiModel *payment;
    SimiPayUIndianModel *model;
    NSDictionary *paymentData;
    NSString *paymentHash;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetPayUIndianPaymentHashConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidUpdatePayUIndianPaymentConfig" object:nil];
        // add observer payu indian
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(success:) name:@"payment_success_notifications" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failure:) name:@"payment_failure_notifications" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancel:) name:@"payu_notifications" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"passData" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {
        
    } else if ([noti.name isEqualToString:@"DidPlaceOrder-After"]) {
        order = [[SimiOrderModel alloc] init];
        order = [noti.userInfo valueForKey:@"data"];
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[[payment valueForKey:@"method_code"] uppercaseString] isEqualToString:@"PAYUBIZ"]) {
            NSDictionary *param = @{@"order_id" : [order objectForKey:@"_id"]};
//            NSDictionary *param = @{@"order_id" : @"56b03703e2bc732f037b23cf"};
            
            self.isDiscontinue = YES;
            if (model == nil) {
                model = [[SimiPayUIndianModel alloc] init];
            }
            [model getPaymentHash:param];
        }
        
    } else if ([noti.name isEqualToString:@"DidUpdatePayUIndianPaymentConfig"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            //
        }
    } else if ([noti.name isEqualToString:@"DidGetPayUIndianPaymentHashConfig"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            paymentHash = [model valueForKey:@"payment_hash"];
            if (paymentData != nil) {
                paymentData = nil;
            }
            paymentData = [model valueForKey:@"data"];
            NSLog(@"payment hash : %@", paymentHash);
                self.hashDict = @{
                                  @"payment_hash" : paymentHash
                                  };
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti {
//    payment = [noti.userInfo valueForKey:@"payment"];
//    if ([[[payment valueForKey:@"method_code"] uppercaseString] isEqualToString:@"PAYUBIZ"]) {
        PayUPaymentOptionsViewController *paymentOptionsVC = nil;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 480)
            {
                paymentOptionsVC = [[PayUPaymentOptionsViewController alloc] initWithNibName:@"AllPaymentOprionsView" bundle:nil];
            }
            else
            {
                paymentOptionsVC = [[PayUPaymentOptionsViewController alloc] initWithNibName:@"PayUPaymentOptionsViewController" bundle:nil];
            }
        }
        //Pass the parameters in paramDict in Key-Value pair as mentioned
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [paymentData valueForKey:@"productinfo"],@"productinfo",
                                      [paymentData valueForKey:@"firstname"],@"firstname",
                                      [paymentData valueForKey:@"amount"],@"amount",
                                      [paymentData valueForKey:@"email"],@"email",
                                      [paymentData valueForKey:@"phone"], @"phone",
                                      [paymentData valueForKey:@"surl"],@"surl",
                                      [paymentData valueForKey:@"furl"],@"furl",
                                      // _txnID is your Transaction ID set by you inside the app
                                      [paymentData valueForKey:@
                                       "txnid"],@"txnid",
                                      @"ra:ra",@"user_credentials",
                                      @"offertest@1411",@"offer_key",
                                      @"u1",@"udf1",
                                      @"u2",@"udf2",
                                      @"u3",@"udf3",
                                      @"u4",@"udf4",
                                      @"u5",@"udf5"
                                      ,nil];
        paymentOptionsVC.parameterDict = paramDict;
        paymentOptionsVC.callBackDelegate = self;
        paymentOptionsVC.totalAmount  = [[paymentData valueForKey:@"amount"] floatValue];
        paymentOptionsVC.appTitle     = @"PayU test App";
        if(_hashDict)
            paymentOptionsVC.allHashDict = _hashDict;
        _hashDict = nil;
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        [(UINavigationController *)currentVC pushViewController:paymentOptionsVC animated:YES];
//    }
}

- (void) success:(NSDictionary *)info{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}
- (void) failure:(NSDictionary *)info{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}
- (void) cancel:(NSDictionary *)info{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}
-(void)dataReceived:(NSNotification *)noti
{
    NSLog(@"dataReceived from surl/furl:%@", noti.object);
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}

@end
