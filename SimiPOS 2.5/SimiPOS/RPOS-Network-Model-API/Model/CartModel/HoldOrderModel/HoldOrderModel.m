//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "HoldOrderModel.h"
#import "HoldOrderAPI.h"

@implementation HoldOrderModel

- (void)holdOrderWithCashIn:(NSString *)cashIn note:(NSString *)note{
    currentNotificationName = @"DidHoldOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_cart.holdOrder" forKey:@"method"];
    [params setValue:cashIn forKey:@"cashin"];
    [params setValue:note forKey:@"note"];
    DLog(@"%@",params);

    [(HoldOrderAPI *) [self getAPI] holdOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
