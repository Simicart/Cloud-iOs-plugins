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
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import <SimiCartBundle/SCPaymentViewController.h>

@implementation SimiPayUIndianWorker {
    SimiOrderModel *order;
    SimiModel *payment;
    SimiPayUIndianModel *model;
    NSDictionary *paymentData;
    NSDictionary *paymentHash;
    SimiViewController *viewController;
    NSString *txn_id;
    NSString *order_id;
    SCPaymentViewController *paymentVC;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetPayUIndianPaymentHashConfig" object:nil];
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
        viewController = [noti.userInfo valueForKey:@"controller"];
        if (!viewController) {
            UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            viewController = [navi.viewControllers lastObject];
        }
        viewController.isDiscontinue = YES;
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[[payment valueForKey:@"method_code"] uppercaseString] isEqualToString:@"PAYUBIZ"]) {
            order = [[SimiOrderModel alloc] init];
            order = [noti.userInfo valueForKey:@"data"];
            NSDictionary *param = @{@"order_id" : [order objectForKey:@"_id"]};
            order_id = [order objectForKey:@"_id"];
            if (model == nil) {
                model = [[SimiPayUIndianModel alloc] init];
            }
            [model getPaymentHash:param];
        }
        
    } else if ([noti.name isEqualToString:@"DidGetPayUIndianPaymentHashConfig"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            paymentHash = [model valueForKey:@"hash"];
            if (paymentHash != nil) {
                self.hashDict = paymentHash;
            }
            if (paymentData != nil) {
                paymentData = nil;
            }
            paymentData = [model valueForKey:@"data"];
            txn_id = [paymentData objectForKey:@"txnid"];
            [self didPlaceOrder:noti];
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti {
    viewController = [noti.userInfo valueForKey:@"controller"];
    if (!viewController) {
        UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        viewController = [navi.viewControllers lastObject];
    }
    viewController.isDiscontinue = YES;
        PayUPaymentOptionsViewController *paymentOptionsVC = nil;
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 480)
            {
                paymentOptionsVC = [[PayUPaymentOptionsViewController alloc] initWithNibName:@"AllPaymentOprionsView" bundle:nil];
            }
            else
            {
                paymentOptionsVC = [[PayUPaymentOptionsViewController alloc] initWithNibName:@"PayUPaymentOptionsViewController" bundle:nil];
            }
//        }
        //Pass the parameters in paramDict in Key-Value pair as mentioned
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [paymentData objectForKey:@"productinfo"],@"productinfo",
                                      [paymentData objectForKey:@"firstname"],@"firstname",
                                      [paymentData objectForKey:@"amount"],@"amount",
                                      [paymentData objectForKey:@"email"],@"email",
                                      @"", @"phone",
                                      [paymentData objectForKey:@"surl"],@"surl",
                                      [paymentData objectForKey:@"furl"],@"furl",
                                      [paymentData objectForKey:@
                                       "txnid"],@"txnid",
                                      @"ra:ra",@"user_credentials",
                                      @"",@"offer_key",
                                      @"",@"udf1",
                                      @"",@"udf2",
                                      @"",@"udf3",
                                      @"",@"udf4",
                                      @"",@"udf5"
                                      ,nil];
    NSLog(@"param : %@", paramDict);
        paymentOptionsVC.parameterDict = paramDict;
        paymentOptionsVC.callBackDelegate = self;
        paymentOptionsVC.totalAmount  = [[paymentData objectForKey:@"amount"] floatValue];
        paymentOptionsVC.appTitle     = @"PayU test App";
        if(_hashDict)
            paymentOptionsVC.allHashDict = _hashDict;
        _hashDict = nil;
    viewController.isDiscontinue = YES;
    paymentOptionsVC.order = order;
    [viewController.navigationController pushViewController:paymentOptionsVC animated:YES];

}

- (void) success:(NSDictionary *)info{
    NSMutableDictionary *updatePaymentParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               order_id, @"order_id",
                                               txn_id, @"txn_id",
                                               @"1", @"status",
                                               nil];
    if (model == nil) {
        model = [[SimiPayUIndianModel alloc] init];
    }
    [model updatePayment:updatePaymentParam];
}
- (void) failure:(NSDictionary *)info{
    NSMutableDictionary *updatePaymentParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               order_id, @"order_id",
                                               txn_id, @"txn_id",
                                               @"2", @"status",
                                               nil];
    if (model == nil) {
        model = [[SimiPayUIndianModel alloc] init];
    }
    [model updatePayment:updatePaymentParam];
    [viewController.navigationController popToRootViewControllerAnimated:YES];

}
- (void) cancel:(NSDictionary *)info{
    [viewController.navigationController popToRootViewControllerAnimated:YES];
}
-(void)dataReceived:(NSNotification *)noti
{
    NSLog(@"dataReceived from surl/furl:%@", noti.object);
    NSLog(@"order_id : %@", order_id);
    NSMutableDictionary *updatePaymentParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            order_id, @"order_id",
                                            txn_id, @"txn_id",
                                            @"1", @"status",
                                               nil];
    if (model == nil) {
        model = [[SimiPayUIndianModel alloc] init];
    }
    [model updatePayment:updatePaymentParam];
}

@end
