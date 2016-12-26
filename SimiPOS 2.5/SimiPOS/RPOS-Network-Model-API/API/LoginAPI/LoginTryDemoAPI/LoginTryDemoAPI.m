//
//  LoginTryDemoAPI.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "LoginTryDemoAPI.h"

@implementation LoginTryDemoAPI

- (void)loginTryDemoWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    NSMutableDictionary* headerParams = [NSMutableDictionary new];
    [headerParams setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [self requestWithMethod:method URL:URL_ACTIVE_KEY params:params target:target selector:selector header:headerParams];
}

@end
