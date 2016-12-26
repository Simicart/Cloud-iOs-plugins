//
//  MagentoOrder.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2016/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
#import "Order.h"

@interface MagentoOrder : MagentoAbstract

- (void)sendEmail:(Order *)order address:(NSString *)email finished:(SEL)finishedMethod;

//invoice
- (void)createInvoice:(Order *)order withData:(NSDictionary *)data finished:(SEL)finishedMethod;

//refund
- (void)createCreditmemo:(Order *)order withData:(NSDictionary *)data finished:(SEL)finishedMethod;

//cancel
- (void)cancel:(Order *)order finished:(SEL)finishedMethod;

//ship
- (void)ship:(Order *)order finished:(SEL)finishedMethod;


- (void)comment:(Order *)order finished:(SEL)finishedMethod;

- (void)loadPrint:(Order *)order finished:(SEL)finishedMethod;

- (void)cancelHoldOrder:(Order *)order finished:(SEL)finishedMethod;

@end
