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
#import <SimiCartBundle/SCPaymentViewController.h>
#import "SimiCartPluginFW-Swift.h"

@implementation SimiCheckOutWorker {
    SimiModel *payment;
    SimiViewController *viewController;
    SimiOrderModel *order;
    SimiCheckOutModel *model;
    NSString *publishKey;
    NSString *isSandBox;
    SCPaymentViewController *paymentVC;
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
    if ([noti.name isEqualToString:@"DidGetCheckOutPublishKeyConfig"]) {
        // lay xong publish key
        // check error
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            publishKey = [model valueForKey:@"public_key"];
            isSandBox = [model valueForKey:@"is_sandbox"];
        }
    }
    else {
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
        checkoutViewController.order = orderData;
        checkoutViewController.isSandBox = isSandBox;
        viewController.isDiscontinue = YES;
        [viewController.navigationController pushViewController:checkoutViewController animated:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:@"Non Publish key" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


@end
