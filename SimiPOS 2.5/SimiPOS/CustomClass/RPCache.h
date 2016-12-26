//
//  RPCache.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/3/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPCache : NSCache <NSCacheDelegate>

#pragma mark - NSCache

- (void)setObject:(id)obj forKey:(id)key;

//- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)num;

- (void)removeObjectForKey:(id)key;

- (void)removeAllObjects;

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache*)cache willEvictObject:(id)obj;

#pragma mark - RPCache

@property (strong, nonatomic) NSMutableDictionary* allKeysRPCache;

- (NSArray*)allKeys;

- (id)init;

@end
