//
//  SimiIpayAPI.m
//  SimiCartPluginFW
//
//  Created by Lionel on 3/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiIpayAPI.h"
#import "SimiGlobalVar+Ipay.h"

@implementation SimiIpayAPI
- (void)getConfigWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetConfig];
    [self requestWithMethod:@"GET" URL:url params:params target:target selector:selector header:nil];
}
- (void)updateIpayOrderWithParams:(NSMutableDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiUpdateIpayPayment];
    [self requestWithMethod:@"POST" URL:url params:params target:target selector:selector header:nil];
}
@end
