//
//  SimiCheckOutWorker.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiCheckOutWorker.h"
#import "SimiCheckOutModel.h"
#import <SimiCartBundle/SimiOrderModel.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import "SimiCartPluginFW-Swift.h"

@implementation SimiCheckOutWorker {
    SimiModel *payment;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiCheckOutModel *model;
    NSString *publishKey;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidCreateCheckOutPaymentConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidCancelOrder object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"CancelOrder" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"DidGetCheckOutPublishKeyConfig"]) {
        // lay xong publish key
        // check error
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            publishKey = [model valueForKey:@"public_key"];
        }
    } else if ([noti.name isEqualToString:@"DidCreateCheckOutPaymentConfig"]) {
        [self didCreatePayment:noti];
    } else if ([noti.name isEqualToString:@"CancelOrder"]) {
        // get order id and call api cancel order
        order = noti.object;
        [order cancelAnOrder:[order objectForKey:@"_id"]];
    } else if ([noti.name isEqualToString:DidCancelOrder]) {
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
            [viewController.navigationController popToRootViewControllerAnimated:YES];
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            UIViewController *currentViewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
            [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentViewController.view permittedArrowDirections:0 animated:YES];
        } else {
            [viewController.navigationController pushViewController:navi animated:YES];
        }
    } else {
        payment = [noti.userInfo valueForKey:@"payment"];
        NSLog(@"payment_method : %@", payment);
        if ([[payment valueForKey:@"method_code"] isEqualToString:@"checkout"]) {
            if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCheckOutPublishKeyConfig" object:nil];
                SimiCheckOutModel *simiCheckOutModel = [[SimiCheckOutModel alloc] init];
                [simiCheckOutModel getPublishKey:nil];
                model = simiCheckOutModel;
            }else if ([noti.name isEqualToString:@"DidPlaceOrder-After"]){
                [self didPlaceOrder:noti];
            }
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti{
    SimiOrderModel *orderData = [[SimiOrderModel alloc] init];
    orderData = [noti.userInfo valueForKey:@"data"];
    viewController = [noti.userInfo valueForKey:@"controller"];
    if (!viewController) {
        UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        viewController = [navi.viewControllers lastObject];
    }
    if (publishKey != nil) {
        CheckOutViewController *checkoutViewController = [[CheckOutViewController alloc] init];
        checkoutViewController.publishKey = publishKey;
        checkoutViewController.simiCheckOutModel = model;
        checkoutViewController.orderData = orderData;
        viewController.isDiscontinue = YES;
        [viewController.navigationController pushViewController:checkoutViewController animated:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:@"Non Publish key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)didCreatePayment:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo objectForKey:@"responder"];
    viewController = [noti.userInfo valueForKey:@"controller"];
    if (!viewController) {
        UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        viewController = [navi.viewControllers lastObject];
    }
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        // get order Data
        SCThankYouPageViewController *thankYouPageViewController = [[SCThankYouPageViewController alloc] init];
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:thankYouPageViewController];
        thankYouPageViewController.order = [[SimiOrderModel alloc] initWithDictionary:model];
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
            [viewController.navigationController popToRootViewControllerAnimated:YES];
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            UIViewController *currentViewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
            [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentViewController.view permittedArrowDirections:0 animated:YES];
        } else {
            [viewController.navigationController pushViewController:navi animated:YES];
        }
    } else {
        // fail
        [viewController.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:@"Some thing wrong. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


@end
