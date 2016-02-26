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
    NSString *directLink;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetPayUDirectLinkConfig" object:nil];
        
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
    } else if ([noti.name isEqualToString:@"DidGetPayUDirectLinkConfig"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            if ([model valueForKey:@"errors"] != nil) {
                NSDictionary *errors = [model valueForKey:@"errors"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please choose another payment.", [errors valueForKey:@"message"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            } else {
                directLink = [model valueForKey:@"url"];
                NSLog(@"direct link : %@", directLink);
                SimiPayUViewController *simiPayUViewController = [[SimiPayUViewController alloc] init];
                simiPayUViewController.stringURL = directLink;
                simiPayUViewController.isDiscontinue = YES;
                simiPayUViewController.orderId = [order objectForKey:@"_id"];
                orderViewController.isDiscontinue = YES;
                [orderViewController.navigationController pushViewController:simiPayUViewController animated:YES];
            }
            
        }
    }
}

- (void)didPlaceOrder:(NSNotification *)noti {
    // call API get directLink
    order = [[SimiOrderModel alloc] init];
    order = [noti.userInfo valueForKey:@"data"];
    payment = [noti.userInfo valueForKey:@"payment"];
    if ([[[payment valueForKey:@"method_code"] uppercaseString] isEqualToString:@"PAYU"] &&[order valueForKey:@"invoice_number"]) {
        NSDictionary *param = @{
                            @"order_id" : [order objectForKey:@"_id"],
                            @"continue_url" : @"http://localhost"
                            };
        if (model == nil) {
            model = [[SimiPayUModel alloc] init];
        }
        [model getDirectLink:param];
    }
}

@end
