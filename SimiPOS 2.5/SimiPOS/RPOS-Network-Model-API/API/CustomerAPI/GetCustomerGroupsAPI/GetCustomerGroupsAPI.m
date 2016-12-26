//
//  GetCustomerGroupsAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "GetCustomerGroupsAPI.h"

@implementation GetCustomerGroupsAPI
- (void)getCustomerGroupsWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
    //    NSMutableDictionary* headerParams = [NSMutableDictionary new];
    //    [headerParams setValue:@"application/json" forKey:@"Content-Type"];
    //    [headerParams setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
};

@end
