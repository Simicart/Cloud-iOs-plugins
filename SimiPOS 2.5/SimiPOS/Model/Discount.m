//
//  Discount.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Discount.h"
#import "MagentoDiscount.h"

@implementation Discount

- (void)addCouponCode:(NSString *)coupon
{
    if (coupon == nil) {
        coupon = @"";
    }
    MagentoDiscount *resource = (MagentoDiscount *)[self getResource];
    [resource addCoupon:self withCoupon:coupon finished:@selector(addCouponCodeSuccess)];
}

- (void)addCouponCodeSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DiscountAddSuccess" object:nil];
}

- (void)addCustomDiscount:(NSDictionary *)custom
{
    if (custom != nil) {
        [self addEntriesFromDictionary:custom];
    }
    MagentoDiscount *resource = (MagentoDiscount *)[self getResource];
    [resource addCustomDiscount:self finished:@selector(addCustomDiscountSuccess)];
}

- (void)addCustomDiscountSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DiscountAddSuccess" object:nil];
}

@end
