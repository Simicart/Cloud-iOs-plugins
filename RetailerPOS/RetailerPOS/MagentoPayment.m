//
//  MagentoPayment.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/22/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoPayment.h"

@implementation MagentoPayment

#pragma mark - implement load collection
-(NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_payment.list" forKey:@"method"];
    return params;
}

#pragma mark - implement save data
-(NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_payment.setMethod" forKey:@"method"];
    [params setValue:@[model] forKey:@"params"];
    return params;
}

@end
