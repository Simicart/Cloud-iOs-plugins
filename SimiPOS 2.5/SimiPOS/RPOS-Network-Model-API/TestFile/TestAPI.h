//
//  SimiCustomerAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosAPI.h"

@interface TestAPI : RetailerPosAPI

- (void)getStoreUrlWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;

- (void)loginTryDemoWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;

@end
