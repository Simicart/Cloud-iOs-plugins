//
//  CurrentBalanceModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CurrentBalanceModel.h"
#import "CurrentBalanceAPI.h"

@implementation CurrentBalanceModel

- (void)getCurrentBalance{
    currentNotificationName = @"DidGetCurrentBalance";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"transaction.getCurrentBalance" forKey:@"method"];
    
    [(CurrentBalanceAPI *) [self getAPI] getCurrentBalanceWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
