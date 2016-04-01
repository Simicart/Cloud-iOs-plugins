//
//  SimiCustomerAPI+Facebook.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/20/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiCustomerAPI+Facebook.h"
#import "SimiGlobalVar+Facebook.h"

@implementation SimiCustomerAPI (Facebook)

- (void)loginFacebookWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiFacebookLogin];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

@end
