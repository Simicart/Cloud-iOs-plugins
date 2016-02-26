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
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderBefore object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:DidPlaceOrderBefore]) {
        orderViewController = [noti.userInfo valueForKey:@"controller"];
    } else
    if ([noti.name isEqualToString:@"DidSelectPaymentMethod"]) {
        // neu co the thi get continue link tai day luon.
        
    } else if ([noti.name isEqualToString:@"DidPlaceOrder-After"]) {
        [self didPlaceOrder:noti];
    }
}

- (void)didPlaceOrder:(NSNotification *)noti {
    // call API get directLink
    
    
    order = [[SimiOrderModel alloc] init];
    order = [noti.userInfo valueForKey:@"data"];
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
