//
//  ShipOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ShipOrderModel.h"
#import "ShipOrderAPI.h"

@implementation ShipOrderModel

- (void)shipOrder:(NSString*)orderID WithItems:(NSDictionary *)items{
    currentNotificationName = @"DidShipOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:items
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *paramsItems = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@,%@", @"\"", orderID, @"\"", paramsItems];
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"ShipOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order_shipment.create" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(ShipOrderAPI *) [self getAPI] shipOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
