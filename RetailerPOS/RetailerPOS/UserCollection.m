//
//  UserCollection.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "UserCollection.h"

@implementation UserCollection

- (id)init
{
    if (self = [super init]) {
        self.modelClass = @"User";
    }
    return self;
}

- (CollectionAbstract *)loadSuccess:(NSDictionary *)data
{
    [super loadSuccess:data];
    NSUInteger n = [self getSize];
    for (NSUInteger i = 0; i < n; i++) {
        ModelAbstract *model = (ModelAbstract *)[self objectAtIndex:i];
        for (id key in [model allKeys]) {
            if ([[model objectForKey:key] isKindOfClass:[NSNull class]]) {
                [model removeObjectForKey:key];
            }
        }
    }
    return self;
}

@end
