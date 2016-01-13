//
//  SimiCustomerAPI+Facebook.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/20/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCustomerAPI.h>

@interface SimiCustomerAPI (Facebook)

- (void)loginFacebookWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
