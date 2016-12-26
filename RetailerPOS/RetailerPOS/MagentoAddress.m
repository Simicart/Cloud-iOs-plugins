//
//  MagentoAddress.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAddress.h"
#import "ModelAbstract.h"

@implementation MagentoAddress

- (void)loadBilling:(ModelAbstract *)object withCustomerId:(NSObject *)identify finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"customer_address.address" forKey:@"method"];
    [params setValue:@[identify] forKey:@"params"];
    
    [self post:params target:(NSObject *)object finished:finishedMethod async:NO];
}

- (void)loadBillingAddress:(ModelAbstract *)object finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"checkout_cart.address" forKey:@"method"];
    [params setValue:@[@"billing"] forKey:@"params"];
    [self post:params target:(NSObject *)object finished:finishedMethod async:NO];
}

- (void)loadShipping:(ModelAbstract *)object finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_cart.address" forKey:@"method"];
    [params setValue:@[@"shipping"] forKey:@"params"];
    [self post:params target:(NSObject *)object finished:finishedMethod async:NO];
}

- (void)saveShipping:(ModelAbstract *)object finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_customer.setAddress" forKey:@"method"];
    [params setValue:@[object] forKey:@"params"];
    
    [self post:params target:(NSObject *)object finished:finishedMethod async:NO];
}

#pragma mark - implement abstract load data

#pragma mark - implement abstract save data
- (NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    NSMutableDictionary *params = [super prepareSave:model withAction:action];
    [params setValue:[NSString stringWithFormat:@"customer_address.%@", action] forKey:@"method"];
    if ([action isEqualToString:@"update"]) {
        [params setValue:@[[model getId], model] forKey:@"params"];
    } else {
        [params setValue:@[[model objectForKey:@"customer_id"], model] forKey:@"params"];
    }
    return params;
}

@end
