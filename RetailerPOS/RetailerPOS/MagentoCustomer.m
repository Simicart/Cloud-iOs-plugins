//
//  MagentoCustomer.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoCustomer.h"
#import "CustomerCollection.h"

@implementation MagentoCustomer

#pragma mark - implement abstract
- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"customer.info" forKey:@"method"];
    return params;
}

- (NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"customer.search" forKey:@"method"];
    
    NSString *searchTerm = [(CustomerCollection *)collection searchTerm];
    if (searchTerm == nil) {
        searchTerm = @"";
    }
    [params setValue:@[searchTerm, [NSNumber numberWithUnsignedInteger: collection.curPage], [NSNumber numberWithUnsignedInteger: collection.pageSize]] forKey:@"params"];
    
    return params;
}

- (NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    NSMutableDictionary *params = [super prepareSave:model withAction:action];
    [params setValue:[NSString stringWithFormat:@"customer.%@", action] forKey:@"method"];
    if ([action isEqualToString:@"update"]) {
        [params setValue:@[[model getId], model] forKey:@"params"];
    } else {
        [params setValue:@[model] forKey:@"params"];
    }
    return params;
}

#pragma mark - special methods
- (void)deleteCustomer:(ModelAbstract *)model finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"customer.delete" forKey:@"method"];
    [params setValue:@[[model getId]] forKey:@"params"];
    
    [self post:params target:(NSObject *)model finished:finishedMethod async:NO];
}

@end
