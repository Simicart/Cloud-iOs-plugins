//
//  SimiOrderModel+PayPal.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiOrderModel.h>

@interface SimiOrderModel (PayPal)

- (void)updateOrderWithPaymentStatus:(PaymentStatus)paymentStatus proof:(NSDictionary *)proof;

@end
