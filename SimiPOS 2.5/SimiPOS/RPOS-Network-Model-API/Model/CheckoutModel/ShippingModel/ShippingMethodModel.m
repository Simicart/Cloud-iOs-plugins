//
//  ShippingMethodModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ShippingMethodModel.h"
#import "ShippingMethodAPI.h"

@implementation ShippingMethodModel

- (void)setShippingMethodWithCode:(NSString *)code{
    currentNotificationName = @"DidSetShippingMethod";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_shipping.setMethod" forKey:@"method"];
    [params setValue:[NSString stringWithFormat:@"[\"%@\"]",code] forKey:@"params"];
    DLog(@"%@",params);

    [(ShippingMethodAPI *) [self getAPI]setShippingMethodWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
