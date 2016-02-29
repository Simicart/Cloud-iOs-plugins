//
//  KlarnaWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import "KlarnaWorker.h"
@implementation KlarnaWorker
{
    SCOrderViewController *orderViewController;
    SimiOrderModel *order;
    SimiModel *payment;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderBefore object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:DidPlaceOrderBefore]) {
        orderViewController = [noti.userInfo valueForKey:@"controller"];
        order = [noti.userInfo valueForKey:@"data"];
        payment = [noti.userInfo valueForKey:@"payment"];
        if ([[payment valueForKey:@"method_code"] isEqualToString:@"klarna"]) {
            orderViewController.isDiscontinue = YES;
            KlarnaViewController *viewController = [[KlarnaViewController alloc] init];
            viewController.order = order;
            [orderViewController.navigationController pushViewController:viewController animated:YES];
            viewController.navigationItem.title = @"Klarna";
            if([[[SimiGlobalVar sharedInstance] currencyCode] isEqualToString:@"USD"] || [[[SimiGlobalVar sharedInstance] currencyCode] isEqualToString:@"GBP"])
                viewController.url = [NSString stringWithFormat:@"http://dev-manage.jajahub.com/klarna/index?order_id=%@&token=%@", [order valueForKey:@"_id"], kSimiKey];
            else
                viewController.url = [NSString stringWithFormat:@"http://dev-manage.jajahub.com/klarna/index?order_id=%@&token=%@", [order valueForKey:@"_id"], kSimiKey];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
