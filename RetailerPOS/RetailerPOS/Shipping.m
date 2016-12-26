//
//  Shipping.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/21/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Shipping.h"
#import "ShippingCollection.h"

@implementation Shipping
@synthesize collection = _collection;

- (id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Shipping";
        // self.collection = [ShippingCollection new];
    }
    return self;
}

- (Shipping *)shippingMethod
{
    if ([self objectForKey:@"id"] == nil
        || [self objectForKey:@"shipping_method"] == nil
        || [[self objectForKey:@"shipping_method"] isKindOfClass:[NSNull class]]
    ) {
        return nil;
    }
    Shipping *shippingMethod;
    for (id key in self.collection.sortedIndex) {
        Shipping *method = [self.collection objectForKey:key];
        if ([[method objectForKey:@"code"] isEqualToString:[self objectForKey:@"shipping_method"]]) {
            shippingMethod = method;
            break;
        }
    }
    return shippingMethod;
}

- (BOOL)isCurrentMethod:(Shipping *)method
{
    if ([self objectForKey:@"id"] == nil
        || [self objectForKey:@"shipping_method"] == nil
        || [[self objectForKey:@"shipping_method"] isKindOfClass:[NSNull class]]
        ) {
        return NO;
    }
    if ([[method objectForKey:@"code"] isEqualToString:[self objectForKey:@"shipping_method"]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Save shipping method
- (void)saveMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShippingSaveMethodBefore" object:self];
    
    [[self getResource] save:self withAction:[self objectForKey:@"code"] finished:@selector(saveMethodSuccess)];
}

- (void)saveMethodSuccess
{
    Shipping *address = [Quote sharedQuote].shipping;
    [address setValue:[self objectForKey:@"code"] forKey:@"shipping_method"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShippingSaveMethodAfter" object:self];
}

@end
