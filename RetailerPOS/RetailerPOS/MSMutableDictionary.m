//
//  MSMutableDictionary.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/18/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSMutableDictionary.h"

@interface MSMutableDictionary()

@property (strong, nonatomic) NSMutableDictionary *_msProxy;

@end

@implementation MSMutableDictionary
-(id)init
{
    if (self = [super init]) {
        self._msProxy = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - NSMutableDictionary methods
-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [self._msProxy setObject:anObject forKey:aKey];
}

-(void)removeObjectForKey:(id)aKey
{
    [self._msProxy removeObjectForKey:aKey];
}

#pragma mark - NSDictionay methods
-(id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self._msProxy = [self._msProxy initWithObjects:objects forKeys:keys count:cnt];
    return self;
}

-(NSUInteger)count
{
    return [self._msProxy count];
}

-(id)objectForKey:(id)aKey
{
    return [self._msProxy objectForKey:aKey];
}

-(NSEnumerator *)keyEnumerator
{
    return [self._msProxy keyEnumerator];
}

@end
