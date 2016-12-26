//
//  Payment.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Payment.h"
#import "PaymentCollection.h"

@implementation Payment
@synthesize collection = _collection;
@synthesize instance = _instance;

- (id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Payment";
        // self.collection = [PaymentCollection new];
    }
    return self;
}

- (BOOL)isCurrentMethod:(Payment *)method
{
    if ([self objectForKey:@"method"] == nil
        || [[self objectForKey:@"method"] isKindOfClass:[NSNull class]]
    ) {
        return NO;
    }
    if ([[self objectForKey:@"method"] isEqualToString:[method getId]]) {
        return YES;
    }
    return NO;
}

#pragma mark - validate payment
- (BOOL)validate
{
    if ([self objectForKey:@"method"] == nil
        || [[self objectForKey:@"method"] isKindOfClass:[NSNull class]]
        || self.instance == nil
    )
    {
        return NO;
    }
    
    
    
    if ([self.instance hasOptionForm]) {
        // Check instance method is required custom data
        for (NSString *field in [self.instance formFields]) {
            if ([self objectForKey:field] == nil
                || [[self objectForKey:field] isKindOfClass:[NSNull class]]
                || ([[self objectForKey:field] isKindOfClass:[NSString class]] && [[self objectForKey:field] isEqualToString:@""])
                || ([[self objectForKey:field] isKindOfClass:[NSNumber class]] && ![[self objectForKey:field] boolValue])
            ) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - payment options (Instance methods)
- (BOOL)hasOptionForm
{
//    if ([self isCreditCardMethod]
//        || [[self getId] isEqualToString:@"purchaseorder"]
//    ) {
//        return YES;
//    }
//    return NO;
    if ([[self getId] isEqualToString:@"payanywhere"]
        || [[self getId] isEqualToString:@"paypalhere"]
    ) {
        return NO;
    }
    return YES;
}

- (BOOL)isCreditCardMethod
{
    if ([self objectForKey:@"ccTypes"] != nil
        && [[self objectForKey:@"ccTypes"] isKindOfClass:[NSDictionary class]]
    ) {
        return YES;
    }
    return NO;
}

- (NSArray *)formFields
{
    if ([self isCreditCardMethod]) {
        // Credit card
        return @[/*@"cc_cid", @"cc_owner", */@"cc_number", @"cc_type", @"cc_exp_year", @"cc_exp_month"];
        
    } else if ([[self getId] isEqualToString:@"purchaseorder"]) {
        return @[@"po_number"];
        
    } else if ([[self getId] containsString:@"multipayment"] ) {
        
        return nil;
        //return @[@"cashforpos_ref_no", @"ccforpos_ref_no",@"cp1forpos_ref_no", @"cp2forpos_ref_no", @"codforpos_ref_no"];
        
        
    } else if ([[self getId] containsString:@"forpos"]) {
               return nil;
        // return @[@"ref_no"];
        
    } else {
        return nil;
    }

}

#pragma mark - credit card info
- (NSString *)cardType
{
    NSDictionary *ccTypes = [self.instance objectForKey:@"ccTypes"];
    if (ccTypes == nil || [ccTypes isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSString *type = [self objectForKey:@"cc_type"];
    if (type == nil) {
        return nil;
    }
    return [ccTypes objectForKey:type];
}

- (NSString *)last4Digit
{
    NSString *ccNumber = [self objectForKey:@"cc_number"];
    if (ccNumber.length < 5) {
        return ccNumber;
    }
    return [ccNumber substringFromIndex:ccNumber.length - 4];
}

#pragma mark - save payment method
- (void)saveMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PaymentSaveMethodBefore" object:self];
    
    [[self getResource] save:self withAction:nil finished:@selector(saveMethodSuccess)];
}

- (void)saveMethodSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PaymentSaveMethodAfter" object:self];
}

@end
