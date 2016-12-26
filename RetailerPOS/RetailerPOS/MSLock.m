//
//  MSLock.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/6/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSLock.h"

@implementation MSLock

+ (NSMutableDictionary *)lockObjects
{
    static NSMutableDictionary *lockObjects = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockObjects = [[NSMutableDictionary alloc] init];
    });
    return lockObjects;
}

+ (void)wait:(NSObject *)object
{
    NSMutableDictionary *lockObjects = [self lockObjects];
    NSLock *lock = [[NSLock alloc] init];
    [lockObjects setValue:lock forKey:[NSString stringWithFormat:@"%p", object]];
    [lock lock];
    while (![lock tryLock]) {
        // Waiting for unlock
    }
    [lockObjects removeObjectForKey:[NSString stringWithFormat:@"%p", object]];
}

+ (void)release:(NSObject *)object
{
    NSMutableDictionary *lockObjects = [self lockObjects];
    NSLock *lock = [lockObjects objectForKey:[NSString stringWithFormat:@"%p", object]];
    if (lock != nil) {
        [lock unlock];
    }
}

@end
