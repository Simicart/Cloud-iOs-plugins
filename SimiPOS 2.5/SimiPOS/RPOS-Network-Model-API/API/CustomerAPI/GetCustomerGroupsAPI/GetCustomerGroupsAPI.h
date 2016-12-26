//
//  GetCustomerGroupsAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosAPI.h"

@interface GetCustomerGroupsAPI : RetailerPosAPI

- (void)getCustomerGroupsWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;


@end
