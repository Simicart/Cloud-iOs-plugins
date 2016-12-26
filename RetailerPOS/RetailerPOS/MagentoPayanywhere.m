//
//  MagentoPayanywhere.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 6/12/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MagentoPayanywhere.h"

@implementation MagentoPayanywhere

- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"payment_payanywhere.info" forKey:@"method"];
    return params;
}

@end
