//
//  PaymentCollection.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/22/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentCollection.h"
#import "Payment.h"

@implementation PaymentCollection

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Payment";
    }
    return self;
}

@end
