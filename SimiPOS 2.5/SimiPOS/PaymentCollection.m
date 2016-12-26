//
//  PaymentCollection.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/22/13.
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
