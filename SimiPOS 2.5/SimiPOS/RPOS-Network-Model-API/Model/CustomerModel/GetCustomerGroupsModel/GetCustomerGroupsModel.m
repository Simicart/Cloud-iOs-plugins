//
//  GetCustomerGroupsModel.m
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "GetCustomerGroupsModel.h"
#import "GetCustomerGroupsAPI.h"

@implementation GetCustomerGroupsModel


- (void)getCustomerGroups{
    currentNotificationName = @"DidGetCustomerGroups";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];

    NSString *method = @"customer.getCustomerGroups";
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];

    DLog(@"%@",params);
    
    [(GetCustomerGroupsAPI *) [self getAPI] getCustomerGroupsWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
