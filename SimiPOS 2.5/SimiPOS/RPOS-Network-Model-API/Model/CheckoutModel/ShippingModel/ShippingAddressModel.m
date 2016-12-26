//
//  ShippingAddressModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ShippingAddressModel.h"
#import "ShippingAddressAPI.h"

@implementation ShippingAddressModel

- (void)getShippingAddress{
    currentNotificationName = @"DidGetShippingAddress";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_cart.address" forKey:@"method"];
    [params setValue:@"[\"shipping\"]" forKey:@"params"];

    DLog(@"%@",params);
    [(ShippingAddressAPI *) [self getAPI]getShippingAddressWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
