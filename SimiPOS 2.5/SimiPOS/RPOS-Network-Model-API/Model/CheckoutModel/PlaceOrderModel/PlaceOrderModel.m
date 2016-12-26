//
//  PlaceOrderModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "PlaceOrderModel.h"
#import "PlaceOrderAPI.h"

@implementation PlaceOrderModel

- (void)placeOrderWidthOptions : (NSDictionary *)options{
    currentNotificationName = @"DidPlaceOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    NSString *method = @"checkout_cart.createOrder";
                                 
    if (options) {
        [paramsDict addEntriesFromDictionary:options];
    }

    paramsArr = [[NSMutableArray alloc]initWithObjects:paramsDict, nil];
    
//    for (NSString *key in [options allKeys]) {
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        [dict setValue:[options objectForKey:key] forKey:key];
//        [paramsArr addObject:dict];
//    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsArr
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *paramsProductId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:paramsProductId forKey:@"params"];
    NSString * orderId =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERD_DEFAULT_ORDERID]];
    [params setValue:orderId forKey:@"hold_order_id"];
    
    DLog(@"%@",params);
    
    [(PlaceOrderAPI *) [self getAPI] placeOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
