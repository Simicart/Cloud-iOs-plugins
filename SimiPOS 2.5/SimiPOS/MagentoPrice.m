//
//  MagentoPrice.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoPrice.h"

@implementation MagentoPrice

#pragma mark - implement abstract
-(NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"checkout_cart.formatPrice" forKey:@"method"];
    return params;
}

@end
