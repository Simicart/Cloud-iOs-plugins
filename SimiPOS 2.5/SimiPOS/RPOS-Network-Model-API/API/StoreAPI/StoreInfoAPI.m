//
//  StoreInfoAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "StoreInfoAPI.h"

@implementation StoreInfoAPI

- (void)getStoreInfoWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}

@end
