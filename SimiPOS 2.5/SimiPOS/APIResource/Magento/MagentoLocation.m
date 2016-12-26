//
//  MagentoLocation.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 4/21/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MagentoLocation.h"

@implementation MagentoLocation

#pragma mark - implement load collection
- (NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"location.all" forKey:@"method"];
    return params;
}

@end
