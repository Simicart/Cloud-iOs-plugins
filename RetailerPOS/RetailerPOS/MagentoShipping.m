//
//  MagentoShipping.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/21/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoShipping.h"

@implementation MagentoShipping

#pragma mark - implement load
- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"checkout_cart.address" forKey:@"method"];
    [params setValue:@[@"shipping"] forKey:@"params"];
    return params;
}

-(void)load:(ModelAbstract *)object withId:(NSObject *)identify finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [self prepareLoad:object];
    [self post:params target:(NSObject *)object finished:finishedMethod async:NO];
}

#pragma mark - implement load collection
-(NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_shipping.list" forKey:@"method"];
    return params;
}

#pragma mark - implement save data
-(NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_shipping.setMethod" forKey:@"method"];
    [params setValue:@[action] forKey:@"params"];
    return params;
}

@end
