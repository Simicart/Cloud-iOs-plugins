//
//  SearchOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OrderDetailModel.h"
#import "OrderDetailAPI.h"

@implementation OrderDetailModel

- (void)getOrderDetail:(NSString*)orderID{
    currentNotificationName = @"DidGetOrderDetail";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@", @"\"", orderID, @"\""];
    
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"OrderDetailModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.info" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(OrderDetailAPI *) [self getAPI] getOrderDetailWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
