//
//  ShippingCollection.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/21/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ShippingCollection.h"
#import "Shipping.h"
#import "MSFramework.h"

@implementation ShippingCollection

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Shipping";
    }
    return self;
}

- (CollectionAbstract *)loadSuccess:(NSDictionary *)data
{
    [super loadSuccess:data];
    
    NSArray *sorted = [self.sortedIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Shipping *method1 = [self objectForKey:obj1];
        Shipping *method2 = [self objectForKey:obj2];
        return [[method1 objectForKey:@"carrierName"] compare:[method2 objectForKey:@"carrierName"] options:NSNumericSearch];
    }];
    [self.sortedIndex setArray:sorted];
    
    return self;
}

@end
