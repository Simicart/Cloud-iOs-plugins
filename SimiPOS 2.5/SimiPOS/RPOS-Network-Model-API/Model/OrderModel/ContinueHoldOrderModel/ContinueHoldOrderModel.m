//
//  ContinueHoldOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ContinueHoldOrderModel.h"
#import "ContinueHoldOrderAPI.h"

@implementation ContinueHoldOrderModel

- (void)continueHoldOrder:(NSString*)orderID{
    currentNotificationName = @"DidContinueHoldOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@", @"\"", orderID, @"\""];
    
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"ContinueHoldOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.holdOrderContinue" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(ContinueHoldOrderAPI *) [self getAPI] continueHoldOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
