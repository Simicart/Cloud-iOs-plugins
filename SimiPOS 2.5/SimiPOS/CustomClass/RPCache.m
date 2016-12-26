//
//  RPCache.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/3/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "RPCache.h"

@implementation RPCache

#pragma mark - NSCache

- (void)setObject:(id)obj forKey:(id)key{
    [super setObject:obj forKey:key];
    [self.allKeysRPCache setObject:obj forKey:key];
}

//- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)num{
//    [super setObject:obj forKey:key];
//    [self.allKeysRPCache setObject:obj forKey:key];
//}

- (void)removeObjectForKey:(id)key{
    [super removeObjectForKey:key];
    [self.allKeysRPCache removeObjectForKey:key];
}

- (void)removeAllObjects{
    [super removeAllObjects];
    [self.allKeysRPCache removeAllObjects];
};

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache*)cache willEvictObject:(id)obj{
    for (NSString *key in [self.allKeysRPCache allKeys]) {
        if ([self.allKeysRPCache objectForKey:key] == obj) {
            [self.allKeysRPCache removeObjectForKey:key];
        }
    }
}

#pragma mark - RPCache


- (NSArray*)allKeys{
    
    return [self.allKeysRPCache allKeys];
}

- (id)init
{
    self = [super init];
    __typeof__(self) __weak weakSelf = self;
    self.allKeysRPCache = [[NSMutableDictionary alloc] init];
    self.delegate = weakSelf;
    return self;
}


@end
