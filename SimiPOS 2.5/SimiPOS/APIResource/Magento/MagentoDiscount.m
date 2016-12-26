//
//  MagentoDiscount.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoDiscount.h"

@implementation MagentoDiscount

#pragma mark - add coupon code and custom discount
- (void)addCoupon:(Discount *)discount withCoupon:(NSString *)code finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_discount.coupon" forKey:@"method"];
    [params setValue:@[code] forKey:@"params"];
    [self post:params target:(NSObject *)discount finished:finishedMethod async:NO];
}

- (void)addCustomDiscount:(Discount *)discount finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_discount.discount" forKey:@"method"];
    NSMutableArray *discountParams = [[NSMutableArray alloc] init];
    [discountParams addObject:[discount objectForKey:@"amount"]];
    if ([discount objectForKey:@"type"]) {
        [discountParams addObject:[discount objectForKey:@"type"]];
    }
    if ([discount objectForKey:@"description"]) {
        [discountParams addObject:[discount objectForKey:@"description"]];
    }
    [params setValue:discountParams forKey:@"params"];
    [self post:params target:(NSObject *)discount finished:finishedMethod async:NO];
}

@end
