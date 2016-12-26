//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CancelOnHoldOrderModel.h"
#import "CancelOnHoldOrderAPI.h"

@implementation CancelOnHoldOrderModel

- (void)cancelHoldOrderWithID:(NSString*)orderID{
    currentNotificationName = @"DidCancelHoldOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSString *method = @"order.holdOrderCancel";
    paramsArr = [[NSMutableArray alloc]initWithObjects:orderID, nil];
    
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
    DLog(@"%@",params);

    [(CancelOnHoldOrderAPI *) [self getAPI] cancelHoldOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
