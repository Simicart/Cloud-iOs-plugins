//
//  MagentoUser.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MagentoUser.h"
#import "UserCollection.h"

@implementation MagentoUser

#pragma mark - implement abstract
- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"user.info" forKey:@"method"];
    return params;
}

- (NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"user.list" forKey:@"method"];
    if (collection.conditions != nil) {
        [params setValue:@[collection.conditions] forKey:@"params"];
    }
    return params;
}

- (NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    NSMutableDictionary *params = [super prepareSave:model withAction:action];
    if ([action isEqualToString:@"update"]) {
        [params setValue:@"user.update" forKey:@"method"];
        [params setValue:@[[model getId], model] forKey:@"params"];
    } else {
        [params setValue:@"user.create" forKey:@"method"];
        [params setValue:@[model] forKey:@"params"];
    }
    [params setValue:[NSNumber numberWithBool:YES] forKey:@"app"];
    return params;
}

#pragma mark - special methods
- (void)deleteUser:(ModelAbstract *)user finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"user.delete" forKey:@"method"];
    [params setValue:@[[user getId]] forKey:@"params"];
    [params setValue:[NSNumber numberWithBool:YES] forKey:@"app"];
    
    [self post:params target:(NSObject *)user finished:finishedMethod async:NO];
}

@end
