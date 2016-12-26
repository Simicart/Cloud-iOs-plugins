//
//  ContinueHoldOrderAPI.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ContinueHoldOrderAPI.h"

@implementation ContinueHoldOrderAPI

- (void)continueHoldOrderWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}

@end
