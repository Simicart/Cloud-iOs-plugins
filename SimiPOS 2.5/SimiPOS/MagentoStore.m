//
//  MagentoStore.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/25/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoStore.h"

@implementation MagentoStore

#pragma mark - implement abstract
- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"storeInfo" forKey:@"method"];
    return params;
}

@end
