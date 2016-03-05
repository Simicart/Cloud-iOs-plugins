//
//  SimiIpayWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiIpayWorker.h"
#import "SimiIpayAPI.h"
#import "SimiIpayModel.h"
#import <SimiCartBundle/SimiOrderModel.h>
#import "SimiIpayViewController.h"
#import <SimiCartBundle/SCAppDelegate.h>

#define METHOD_IPAY @"ipay"
#define ALERT_VIEW_ERROR 0

@implementation SimiIpayWorker{
    SimiModel *payment;
    SimiIpayModel *orderInfo;
    NSString *payPalAppKey;
    NSString *payPalReceiverEmail;
    NSString *bnCode;
    SimiViewController *viewController;
    SimiIpayModel *order;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-Before" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-Before"]){

    } else if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {

    } else if ([noti.name isEqualToString:@"DidPlaceOrder-After"]) {
        NSLog(@"noti after get config : %@", noti);
        payment = [noti.userInfo valueForKey:@"payment"];
        orderInfo = noti.object;
        NSLog(@"payment after did place : %@", payment);
        if ([[payment valueForKey:@"method_code"] isEqualToString:METHOD_IPAY]) {
            [self didSelectedPaymentMethod:noti];
        }
    } else if ([noti.name isEqualToString:@"DidGetConfig"]) {
        NSLog(@"noti after get config : %@", noti);
        payment = nil;
        payment = noti.object;
        [self didPlaceOrder:noti];
    }
}

- (void)didSelectedPaymentMethod:(NSNotification *)noti {
    if (order == nil) {
        order = [[SimiIpayModel alloc] init];
        [order getConfigWithParams:nil];
    }
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
//    order = [noti.userInfo objectForKey:@"data"];
    if(order != nil && payment != nil){
        SimiIpayViewController *nextController = [[SimiIpayViewController alloc] init];
        nextController.title =  SCLocalizedString(@"Ipay88");
        NSLog(@"orderInfo : %@", orderInfo);
        nextController.order = orderInfo;
        nextController.payment = payment;
        [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Sorry, Ipay88 is not now available. Please try again later.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_ERROR;
        [alertView show];
    }
}



@end
