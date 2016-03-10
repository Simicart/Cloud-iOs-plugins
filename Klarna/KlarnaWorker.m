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
    KlarnaModel* klarnaModel;
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
        if(!klarnaModel)
            klarnaModel = [KlarnaModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetKlarnaURL object:nil];
        
        if([[payment valueForKey:@"method_code"] isEqualToString:@"klarna"]){
            [orderViewController startLoadingData];
            [klarnaModel getKlarnaURLWithOrder:[order valueForKey:@"_id"]];
        }else if([[payment valueForKey:@"method_code"] isEqualToString:@"klarna_us"]){
            [orderViewController startLoadingData];
            [klarnaModel getKlarnaUSURLWithOrder:[order valueForKey:@"_id"]];
        }
    }else if([noti.name isEqualToString:DidGetKlarnaURL]){
        SimiResponder* responder = [noti.userInfo objectForKey:@"responder"];
        [orderViewController stopLoadingData];
        if([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]){
            [[NSNotificationCenter defaultCenter] removeObserver:self name:DidGetKlarnaURL object:nil];
            if(![klarnaModel objectForKey:@"errors"]){
                orderViewController.isDiscontinue = YES;
                KlarnaViewController *viewController = [[KlarnaViewController alloc] init];
                viewController.order = order;
                [orderViewController.navigationController pushViewController:viewController animated:YES];
                viewController.navigationItem.title = @"Klarna";
                viewController.url = [klarnaModel valueForKey:@"url"];
            }else{
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:SCLocalizedString(@"Something went wrong") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
