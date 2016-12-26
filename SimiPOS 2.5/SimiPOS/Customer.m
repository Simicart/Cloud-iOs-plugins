//
//  Customer.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Customer.h"
#import "MagentoCustomer.h"

@implementation Customer

-(id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Customer";
    }
    return self;
}

#pragma mark - delete customer
- (void)deleteCustomer
{
    MagentoCustomer *resource = (MagentoCustomer *)[self getResource];
    [resource deleteCustomer:self finished:@selector(deleteCustomerSuccess)];
}

- (void)deleteCustomerSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomerDeleteAfter" object:self];
}

@end
