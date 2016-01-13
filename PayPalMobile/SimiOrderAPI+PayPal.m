//
//  SimiOrderAPI+PayPal.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderAPI+PayPal.h"
#import "SimiGlobalVar+PayPal.h"

@implementation SimiOrderAPI (PayPal)

- (void)updateOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiUpdatePayPalPayment];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

@end
