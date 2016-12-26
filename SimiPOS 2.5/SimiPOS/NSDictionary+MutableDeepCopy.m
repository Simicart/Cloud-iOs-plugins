//
//  NSDictionary+MutableDeepCopy.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "NSDictionary+MutableDeepCopy.h"

@implementation NSDictionary (MutableDeepCopy)

- (NSMutableDictionary *)mutableDeepCopy {
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    NSArray *keys = [self allKeys];
    for (id key in keys) {
        id onValue = [self valueForKey:key];
        id onCopy = nil;
        
        if ([onValue respondsToSelector:@selector(mutableDeepCopy)]) {
            onCopy = [onValue mutableDeepCopy];
        } else if ([onValue respondsToSelector:@selector(mutableCopy)]) {
            onCopy = [onValue mutableCopy];
        }
        if (onCopy == nil) {
            onCopy = [onValue copy];
        }
        [returnDict setValue:onCopy forKey:key];
    }
    return returnDict;
}

@end
