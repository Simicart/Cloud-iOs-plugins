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
    NSDictionary *paymentHash;
    SimiViewController *viewController;
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
            paymentHash = [model valueForKey:@"hash"];
            if (paymentHash != nil) {
                self.hashDict = paymentHash;
            }
            if (paymentData != nil) {
                paymentData = nil;
            }
            paymentData = [model valueForKey:@"data"];
            
//                self.hashDict = @{
//                                  @"payment_hash" : paymentHash,
//                                  @"check_offer_status_hash" : [model valueForKey:@"check_offer_status_hash"],
//                                  @"delete_user_card_hash" : [model valueForKey:@"delete_user_card_hash"],
//                                  @"edit_user_card_hash" : [model valueForKey:@"edit_user_card_hash"],
//                                  @"get_merchant_ibibo_codes_hash" : [model valueForKey:@"get_merchant_ibibo_codes_hash"],
//                                  @"get_user_cards_hash" : [model valueForKey:@"get_user_cards_hash"],
//                                  @"payment_related_details_for_mobile_sdk_hash" : [model valueForKey:@"payment_related_details_for_mobile_sdk_hash"],
//                                  @"save_user_card_hash" : [model valueForKey:@"save_user_card_hash"],
//                                  @"vas_for_mobile_sdk_hash" : [model valueForKey:@"vas_for_mobile_sdk_hash"],
//                                  };
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
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        [(UINavigationController *)currentVC pushViewController:paymentOptionsVC animated:YES];
//    }
}

- (void) success:(NSDictionary *)info{
    [viewController.navigationController popToRootViewControllerAnimated:YES];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}
- (void) failure:(NSDictionary *)info{
    [viewController.navigationController popToRootViewControllerAnimated:YES];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}
- (void) cancel:(NSDictionary *)info{
    [viewController.navigationController popToRootViewControllerAnimated:YES];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
}
-(void)dataReceived:(NSNotification *)noti
{
    NSLog(@"dataReceived from surl/furl:%@", noti.object);
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [currentVC.navigationController popToRootViewControllerAnimated:YES];
    [viewController.navigationController popToRootViewControllerAnimated:YES];
}

@end
