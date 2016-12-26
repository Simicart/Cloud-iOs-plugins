//
//  Address.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Address : ModelAbstract

// Load billing address
- (void)loadBilling:(NSObject *)customerId;
- (void)loadBillingAddress;
- (void)loadBillingSuccess;

// Load shipping address
- (void)loadShipping;
- (void)loadShippingSuccess;

// Save shipping address
- (void)saveShipping;
- (void)saveShippingSuccess;

// Repair street address
- (void)repairStreetAddress;

- (void)implodeAddressLines;

@end
