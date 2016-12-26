//
//  Address.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Address.h"
#import "MagentoAddress.h"

@implementation Address

-(id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Address";
    }
    return self;
}

#pragma mark - load billing address
- (void)loadBilling:(NSObject *)customerId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadBefore" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressLoadBefore" object:self];
    
    [(MagentoAddress *)[self getResource] loadBilling:self withCustomerId:customerId finished:@selector(loadBillingSuccess)];
}

- (void)loadBillingAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadBefore" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressLoadBefore" object:self];
    
    [(MagentoAddress *)[self getResource] loadBillingAddress:self finished:@selector(loadBillingSuccess)];
}

- (void)loadBillingSuccess
{
    [self repairStreetAddress];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadAfter" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressLoadAfter" object:self];
}

#pragma mark - repair street address
- (void)repairStreetAddress
{
    NSString *street = [self objectForKey:@"street"];
    if (street == nil || ![street isKindOfClass:[NSString class]]) {
        return;
    }
    NSArray *streets = [street componentsSeparatedByString:@"\n"];
    for (NSUInteger i = 0; i < [streets count]; i++) {
        [self setValue:[streets objectAtIndex:i] forKey:[NSString stringWithFormat:@"street[%d]", (int)i]];
    }
}

- (void)implodeAddressLines
{
    NSString *line1 = [self objectForKey:@"street[0]"];
    if (line1 == nil) {
        line1 = @"";
    } else {
        [self removeObjectForKey:@"street[0]"];
    }
    NSString *line2 = [self objectForKey:@"street[1]"];
    if (line2) {
        [self setValue:[NSString stringWithFormat:@"%@\n%@", line1, line2] forKey:@"street"];
        [self removeObjectForKey:@"street[1]"];
    } else {
        [self setValue:line1 forKey:@"street"];
    }
}

#pragma mark - load shipping address
- (void)loadShipping
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadBefore" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressLoadBefore" object:self];
    
    [(MagentoAddress *)[self getResource] loadShipping:self finished:@selector(loadShippingSuccess)];
}

- (void)loadShippingSuccess
{
    [self repairStreetAddress];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadAfter" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressLoadAfter" object:self];
}

#pragma mark - save shipping address
- (void)saveShipping
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractSaveBefore" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressSaveBefore" object:self];
    
    [(MagentoAddress *)[self getResource] saveShipping:self finished:@selector(saveShippingSuccess)];
}

- (void)saveShippingSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractSaveAfter" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressSaveAfter" object:self];
}

@end
