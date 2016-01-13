//
//  SimiOrderAPI+PayPal.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiOrderAPI.h>

@interface SimiOrderAPI (PayPal)

- (void)updateOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
