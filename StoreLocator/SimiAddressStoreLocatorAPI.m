//
//  SimiAddressStoreLocatorAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiAddressStoreLocatorAPI.h"
#import "SimiGlobalVar+StoreLocator.h"
@implementation SimiAddressStoreLocatorAPI
- (void)getCountryListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetCountryList];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
