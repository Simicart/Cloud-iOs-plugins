//
//  PrintOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "PrintOrderModel.h"
#import "PrintOrderAPI.h"

@implementation PrintOrderModel

- (void)getPrintOrder:(NSString*)orderID{
    currentNotificationName = @"DidGetPrintOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@", @"\"", orderID, @"\""];
    
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"PrintOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.getPrintLink" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(PrintOrderAPI *) [self getAPI] getPrintOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
