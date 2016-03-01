//
//  SimiPayUWorker.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUWorker.h"
#import "SimiPayUModel.h"
#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>

@implementation SimiPayUWorker {
    SimiOrderModel *order;
    SimiModel *payment;
    SimiPayUModel *model;
//    SimiViewController *viewController;
    SCOrderViewController *orderViewController;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:DidCancelOrder object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:@"CancelOrder" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderBefore object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {
        // neu co the thi get continue link tai day luon.
        
    } else if ([noti.name isEqualToString:@"DidPlaceOrder-After"]) {
        [self didPlaceOrder:noti];
    } else if ([noti.name isEqualToString:@"CancelOrder"]) {
        // get order id and call api cancel order
        order = noti.object;
        payment = [order objectForKey:@"payment"];
        if ([[payment valueForKey:@"method_code"] isEqualToString:@"payu"]) {
            [order cancelAnOrder:[order objectForKey:@"_id"]];
        }
    } else if ([noti.name isEqualToString:DidCancelOrder]) {
        order = noti.object;
        payment = [order objectForKey:@"payment"];
        if ([[payment valueForKey:@"method_code"] isEqualToString:@"payu"]) {
            SCThankYouPageViewController *thankYouPageViewController = [[SCThankYouPageViewController alloc] init];
            UINavigationController *navi;
            navi = [[UINavigationController alloc]initWithRootViewController:thankYouPageViewController];
            thankYouPageViewController.order = order;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                [_popController dismissPopoverAnimated:YES];
                thankYouPageViewController.popOver = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [orderViewController.navigationController popToRootViewControllerAnimated:YES];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                UIViewController *currentViewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentViewController.view permittedArrowDirections:0 animated:YES];
            } else {
                [orderViewController.navigationController pushViewController:navi animated:YES];
            }
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti {
    // call API get directLink
    order = [[SimiOrderModel alloc] init];
    order = [noti.userInfo valueForKey:@"data"];
    orderViewController = [noti.userInfo valueForKey:@"controller"];
    payment = [noti.userInfo valueForKey:@"payment"];
    if ([[[payment valueForKey:@"method_code"] uppercaseString] isEqualToString:@"PAYU"] &&[order valueForKey:@"invoice_number"]) {
        SimiPayUViewController *simiPayUViewController = [[SimiPayUViewController alloc] init];
        simiPayUViewController.isDiscontinue = YES;
        if ([order objectForKey:@"_id"] != nil) {
            simiPayUViewController.order = order;
            orderViewController.isDiscontinue = YES;
            [orderViewController.navigationController pushViewController:simiPayUViewController animated:YES];
        }
    }
}

@end
