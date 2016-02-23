//
//  SimiCustomerModel+Facebook.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/20/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiCustomerModel+Facebook.h"

@implementation SimiCustomerModel (Facebook)

- (void)loginWithFacebookEmail:(NSString *)email name:(NSString *)name{
    currentNotificationName = DidLogin;
    [(SimiCustomerAPI *)[self getAPI] loginFacebookWithParams:@{@"email":email, @"first_name":name, @"last_name":@""} target:self selector:@selector(didFinishRequest:responder:)];
}


@end
