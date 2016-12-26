//
//  SearchOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SearchOrderModel.h"
#import "SearchOrderAPI.h"

@implementation SearchOrderModel

- (void)getOrder:(NSString*)offset limit:(NSString*)limit keySearch:(NSString*)keyword isHoldOrder:(NSString*)isHoldOrder{
    currentNotificationName = @"DidGetOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramKeyWord = [NSString stringWithFormat:@"%@%@%@", @"\"", keyword, @"\""];
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@,%@,%@]", paramKeyWord, offset, limit ];
    
    DLog(@"SearchOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.search" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    if([isHoldOrder isEqualToString:@"1"]){
        [params setValue:isHoldOrder forKey:@"holdorder"];
    }
    
    [(SearchOrderAPI *) [self getAPI] getOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

- (void) removeCache:(NSString*)offset limit:(NSString*)limit keySearch:(NSString*)keyword isHoldOrder:(NSString*)isHoldOrder{
    NSString *paramKeyWord = [NSString stringWithFormat:@"%@%@%@", @"\"", keyword, @"\""];
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@,%@,%@]", paramKeyWord, offset, limit ];
    
    DLog(@"SearchOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order.search" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    if([isHoldOrder isEqualToString:@"1"]){
        [params setValue:isHoldOrder forKey:@"holdorder"];
    }
    
    [[RetailerPosNetworkManager sharedInstance] removeCacheFromKey:url params:params];
}

- (void)removeCacheHoldOrder{
    [[RetailerPosNetworkManager sharedInstance] removeCacheWithKeyWord:@"holdorder"];
}

@end
