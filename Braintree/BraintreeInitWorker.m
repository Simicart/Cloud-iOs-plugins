//
//  BraintreeInitWorker.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "BraintreeInitWorker.h"
#import <SimiCartBundle/SimiPaymentModelCollection.h>
#import "BTPaymentViewController.h"
#import <SimiCartBundle/SimiOrderModel.h>

@implementation BraintreeInitWorker
{
    SimiViewController *currentVC;
    NSString* clientToken, *appleMerchant;
    NSArray* listBraintreePayments;
}
-(instancetype) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSelectPaymentMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderAfter object:nil];
        [BTAppSwitch setReturnURLScheme:[NSString stringWithFormat:@"%@.payments",[NSBundle mainBundle].bundleIdentifier]];
    }
    return self;
}

-(void) didReceiveNotification:(NSNotification *)noti{
    if([noti.name isEqualToString:@"ApplicationOpenURL"]){
        NSURL *url = [noti.userInfo valueForKey:@"url"];
        NSString* sourceApplication = [noti.name valueForKey:@"sourceApplication"];
        NSNumber* number = noti.object;
        if ([url.scheme localizedCaseInsensitiveCompare:@"com.simicart.demo.payments"] == NSOrderedSame) {
            number = [NSNumber numberWithBool:[BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication]];
        }
    }else if([noti.name isEqualToString:@"DidSelectPaymentMethod"]){
        NSDictionary* payment = (NSDictionary*) [noti.userInfo valueForKey:@"payment"];
        if([[payment valueForKey:@"method_code"] isEqualToString:@"braintree"]){
            
            SimiBraintreeModel* braintreeModelGetSetting = [SimiBraintreeModel new];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:BRAINTREEGETSETTING object:braintreeModelGetSetting];
            SimiBraintreeModel* braintreeModelGetToken = [SimiBraintreeModel new];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:BRAINTREEGETTOKEN object:braintreeModelGetToken];
            [braintreeModelGetToken getToken];
            [braintreeModelGetSetting getSetting];
        }
        
    }else if([noti.name isEqualToString:DidPlaceOrderAfter]){
        if([[[noti.userInfo valueForKey:@"payment"] valueForKey:@"method_code"] isEqualToString:@"braintree"]){
            currentVC = [noti.userInfo valueForKey:@"controller"];
            currentVC.isDiscontinue = YES;
            BTPaymentViewController* btPaymentVC = [[BTPaymentViewController alloc] init];
            btPaymentVC.listBraintreePayments = [[NSMutableArray alloc] initWithArray:listBraintreePayments];;
            btPaymentVC.clientToken = clientToken;
            btPaymentVC.appleMerchant = appleMerchant;
            btPaymentVC.order = (SimiOrderModel* ) noti.object;
            [currentVC.navigationController pushViewController:btPaymentVC animated:YES];
        }
    }else if([noti.name isEqualToString:BRAINTREEGETSETTING]){
        SimiBraintreeModel* braintreeModel = noti.object;
        appleMerchant = [braintreeModel valueForKey:@"apple_merchant"];
        listBraintreePayments = [braintreeModel valueForKey:@"payment"];
        [self removeObserverForNotification:noti];
    }else if([noti.name isEqualToString:BRAINTREEGETTOKEN]){
        SimiBraintreeModel* braintreeModel = noti.object;
        clientToken = [braintreeModel valueForKey:@"token"];
        [self removeObserverForNotification:noti];
    }
}

@end
