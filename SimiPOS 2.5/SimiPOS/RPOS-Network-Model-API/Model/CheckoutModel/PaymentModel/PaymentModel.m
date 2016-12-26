//
//  PaymentModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "PaymentModel.h"
#import "PaymentAPI.h"

@implementation PaymentModel

- (void)getPaymentList{
    currentNotificationName = @"DidGetPaymentList";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_payment.list" forKey:@"method"];
    DLog(@"%@",params);
    
    [(PaymentAPI *) [self getAPI]getPaymentListWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
