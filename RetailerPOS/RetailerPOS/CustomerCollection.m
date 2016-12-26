//
//  CustomerCollection.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CustomerCollection.h"

@implementation CustomerCollection
@synthesize searchTerm = _searchTerm;

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Customer";
    }
    return self;
}

- (CollectionAbstract *)partialLoadSuccess:(NSDictionary *)data
{
    NSUInteger i = [self getSize];
    [super partialLoadSuccess:data];
    NSUInteger n = [self getSize];
    for (; i < n; i++) {
        ModelAbstract *model = (ModelAbstract *)[self objectAtIndex:i];
        for (id key in [model allKeys]) {
            if ([[model objectForKey:key] isKindOfClass:[NSNull class]]) {
                [model removeObjectForKey:key];
            }
        }
    }
    return self;
}

#pragma mark - add search term
- (BOOL)hasSearchTerm
{
    if (self.searchTerm) {
        return YES;
    }
    return NO;
}

@end
