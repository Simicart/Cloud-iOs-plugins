//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ShippingModel.h"
#import "ShippingAPI.h"

@implementation ShippingModel

- (void)getShippingList{
    currentNotificationName = @"DidGetShippingList";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_shipping.list" forKey:@"method"];
    DLog(@"%@",params);

    [(ShippingAPI *) [self getAPI]getShippingListWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
