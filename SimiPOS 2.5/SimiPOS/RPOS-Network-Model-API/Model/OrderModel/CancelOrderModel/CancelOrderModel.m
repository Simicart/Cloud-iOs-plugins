//
//  CancelOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CancelOrderModel.h"
#import "CancelOrderAPI.h"

@implementation CancelOrderModel

- (void)cancelOrder:(NSString*)orderID{
    currentNotificationName = @"DidCancelOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@", @"\"", orderID, @"\""];
    
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"CancelOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.cancel" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(CancelOrderAPI *) [self getAPI] cancelOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
