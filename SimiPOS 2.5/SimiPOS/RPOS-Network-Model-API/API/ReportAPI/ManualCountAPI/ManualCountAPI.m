//
//  ManualCountAPI.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ManualCountAPI.h"

@implementation ManualCountAPI

- (void)getManualCountWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}

@end
