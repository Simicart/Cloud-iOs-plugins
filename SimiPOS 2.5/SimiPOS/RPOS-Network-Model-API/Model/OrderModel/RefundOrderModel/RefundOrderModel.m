//
//  RefundOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RefundOrderModel.h"
#import "RefundOrderAPI.h"

@implementation RefundOrderModel

- (void)refundOrder:(NSString*)orderID WithForms:(NSDictionary *)form{
    currentNotificationName = @"DidRefundOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:form
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *paramsForm = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@,%@", @"\"", orderID, @"\"", paramsForm];
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"RefundOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order_creditmemo.create" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(RefundOrderAPI *) [self getAPI] refundOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
