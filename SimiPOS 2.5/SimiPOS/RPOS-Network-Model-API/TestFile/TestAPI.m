//
//  SimiCustomerAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "TestAPI.h"

@implementation TestAPI

- (void)getStoreUrlWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    NSString *url = @"http://www.magestore.com/posmanagement/api";

//    [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiConnectorURL, kSimiOrderTracking];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}

- (void)loginTryDemoWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    NSString *url = @"http://www.magestore.com/posmanagement/api";

    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}


@end
