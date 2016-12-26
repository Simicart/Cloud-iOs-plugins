//
//  PaymentMethodModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "PaymentMethodModel.h"
#import "PaymentMethodAPI.h"

@implementation PaymentMethodModel

- (void)setPaymentMethodWithParams:(NSDictionary *)dataParams{
    currentNotificationName = @"DidSetPaymentMethod";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSString *method = @"checkout_payment.setMethod";
    paramsArr = [[NSMutableArray alloc]initWithObjects:dataParams, nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsArr
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *paramsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:paramsStr forKey:@"params"];
    DLog(@"%@",params);
    
    [(PaymentMethodAPI *) [self getAPI]setPaymentMethodWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
