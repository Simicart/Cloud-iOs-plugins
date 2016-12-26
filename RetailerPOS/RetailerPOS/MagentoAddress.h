//
//  MagentoAddress.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"

@interface MagentoAddress : MagentoAbstract

- (void)loadBilling:(ModelAbstract *)object withCustomerId:(NSObject *)identify finished:(SEL)finishedMethod;
- (void)loadBillingAddress:(ModelAbstract *)object finished:(SEL)finishedMethod;
- (void)loadShipping:(ModelAbstract *)object finished:(SEL)finishedMethod;
- (void)saveShipping:(ModelAbstract *)object finished:(SEL)finishedMethod;

@end
