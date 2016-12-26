//
//  MagentoProduct.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/18/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoProduct.h"
#import "Product.h"

@implementation MagentoProduct

#pragma mark - implement abstract
-(NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"product.info" forKey:@"method"];
    return params;
}

-(NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [super prepareLoadCollection:collection];
    [params setValue:@"product.list" forKey:@"method"];
    if ([[[Configuration globalConfig] objectForKey:@"in_stock"] boolValue]) {
        NSMutableArray *functionParams = [params objectForKey:@"params"];
        [functionParams addObject:[[Configuration globalConfig] objectForKey:@"in_stock"]];
    }
    return params;
}

#pragma mark - other resource methods

-(NSMutableArray *)loadOptions:(Product *)product
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    [self post:[[NSDictionary alloc] initWithObjectsAndKeys:@"product.options", @"method", [product getId], @"params", nil] target:options finished:nil async:NO];
    return options;
}

- (void)loadDetail:(Product *)product withId:(NSObject *)identify finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"product.detail" forKey:@"method"];
    [params setValue:identify forKey:@"params"];
    [self post:params target:(NSObject *)product finished:finishedMethod async:NO];
}

@end
