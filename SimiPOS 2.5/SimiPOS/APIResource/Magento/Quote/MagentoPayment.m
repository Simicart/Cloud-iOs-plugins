//
//  MagentoPayment.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/22/13.
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
