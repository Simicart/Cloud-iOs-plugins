//
//  SimiCustomerModel+Facebook.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/20/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCustomerModel.h>
#import "SimiCustomerAPI+Facebook.h"

@interface SimiCustomerModel (Facebook)

- (void)loginWithFacebookEmail:(NSString *)email name:(NSString *)name;

@end
