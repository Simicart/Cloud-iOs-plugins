//
//  SimiCustomerModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "TestModel.h"
#import "TestAPI.h"

@implementation TestModel

- (void)getStoreUrl{
    currentNotificationName = @"DidTrakingOrder";
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"pos57b57a8693853" forKey:@"api_key"];
    [params setValue:@"getStoreUrl" forKey:@"method"];
//    @{@"api_key":@"pos57b57a8693853",@"method":@"getStoreUrl"}
    
    
    
    [(TestAPI *) [self getAPI] getStoreUrlWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
//     trakingOrderWithParams:@{@"order_id":orderId} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)loginTryDemo{
    
}




@end
