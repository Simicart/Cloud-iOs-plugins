//
//  SimiConfigSearchStoreLocatorAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiConfigSearchStoreLocatorAPI.h"
#import "SimiGlobalVar+StoreLocator.h"
@implementation SimiConfigSearchStoreLocatorAPI
- (void)getSearchConfigWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetSearchConfig];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
