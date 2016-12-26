//
//  AddToCartAPI.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "AddToCartAPI.h"

@implementation AddToCartAPI

- (void)addToCartWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
//    NSMutableDictionary* headerParams = [NSMutableDictionary new];
//    [headerParams setValue:@"application/json" forKey:@"Content-Type"];
//    [headerParams setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}

@end
