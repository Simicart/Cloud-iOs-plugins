//
//  SendEmailOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SendEmailOrderModel.h"
#import "SendEmailOrderAPI.h"

@implementation SendEmailOrderModel

- (void)sendEmail:(NSString*)orderID email:(NSString*)email{
    currentNotificationName = @"DidSendEmail";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@,%@%@%@", @"\"", orderID, @"\"", @"\"", email, @"\""];
    
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"SendEmailOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.email" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(SendEmailOrderAPI *) [self getAPI] sendEmailWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
