//
//  MagentoCategory.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoCategory.h"
#import "CategoryCollection.h"

@implementation MagentoCategory

#pragma mark - implement abstract
-(NSMutableDictionary *)prepareLoadCollection:(CategoryCollection *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"category.tree" forKey:@"method"];
    if (collection.rootCategoryId) {
        [params setValue:[NSNumber numberWithUnsignedInteger:collection.rootCategoryId] forKey:@"params"];
    }
    return params;
}

@end
