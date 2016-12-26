//
//  MagentoRegion.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/10/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoRegion.h"
#import "RegionCollection.h"

@implementation MagentoRegion

#pragma mark - implement load collection
- (NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"locale.region" forKey:@"method"];
    [params setValue:@[[(RegionCollection *)collection countryCode]] forKey:@"params"];
    return params;
}

@end
