//
//  Permission.h
//  RetailerPOS
//
//  Created by mac on 3/23/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Permission : NSManagedObject

@property (nullable, nonatomic, retain) NSNumber *all_cart_discount;
@property (nullable, nonatomic, retain) NSNumber *cart_coupon;
@property (nullable, nonatomic, retain) NSNumber *cart_custom_discount;
@property (nullable, nonatomic, retain) NSNumber *items_discount;
@property (nullable, nonatomic, retain) NSNumber *items_custom_price;
@property (nullable, nonatomic, retain) NSNumber *manage_cash_drawer;
@property (nullable, nonatomic, retain) NSNumber *manage_order;
@property (nullable, nonatomic, retain) NSNumber *manage_order_refund;
@property (nullable, nonatomic, retain) NSNumber *maximum_discount_percent;
@property (nullable, nonatomic, retain) NSNumber *all_reports;
@property (nullable, nonatomic, retain) NSNumber *sales_report;
@property (nullable, nonatomic, retain) NSNumber *x_report;
@property (nullable, nonatomic, retain) NSNumber *z_report;
@property (nullable, nonatomic, retain) NSNumber *eod_report;

@end

