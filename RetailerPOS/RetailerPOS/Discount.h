//
//  Discount.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/17/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Discount : ModelAbstract

- (void)addCouponCode:(NSString *)coupon;
- (void)addCouponCodeSuccess;

- (void)addCustomDiscount:(NSDictionary *)custom;
- (void)addCustomDiscountSuccess;

@end
