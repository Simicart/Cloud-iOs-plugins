//
//  CollectionAbstract.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/17/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"
#import "Configuration.h"

@implementation CollectionAbstract
@synthesize modelClass = _modelClass;

@synthesize pageSize = _pageSize;
@synthesize curPage = _curPage;
@synthesize conditions = _conditions;

@synthesize loadCollectionFlag = _loadCollectionFlag;
@synthesize sortedIndex = _sortedIndex;

- (id)init
{
    if (self = [super init]) {
        self.loadCollectionFlag = NO;
        
        self.pageSize = 0;
        self.curPage = 1;
        
        self.sortedIndex = [[NSMutableArray alloc] init];
    }
    return self;
}

// Index by sorted data collection
- (id)objectAtIndex:(NSUInteger)index
{
    return [self objectForKey:[self.sortedIndex objectAtIndex:index]];
}

// Count total product of collection
- (NSUInteger)getSize
{
    return [self.sortedIndex count];
}

#pragma mark - Collection methods
- (CollectionAbstract *)load
{
    if (self.loadCollectionFlag) {
        return self;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionAbstractLoadBefore" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Collection%@LoadBefore", self.modelClass] object:self];
    
    [[self getResource] loadCollection:self finished:@selector(loadSuccess:)];
    
    return self;
}

- (CollectionAbstract *)loadSuccess:(NSDictionary *)data
{
    // Add data to current collection
    for (NSUInteger i = 0, mi = 0; i < [[data allKeys] count]; i++, mi++) {
        NSObject *identify = [[data allKeys] objectAtIndex:i];
        if ([identify isEqual:@"total"]) {
            self.totalItems = [[data objectForKey:identify] unsignedIntegerValue];
            mi--;
            continue;
        }
        ModelAbstract *model = [[self getModel] setData:(NSDictionary *)[data objectForKey:identify]];
        [model setValue:identify forKey:@"id"];
        [self.sortedIndex setObject:[NSNumber numberWithInteger:mi] atIndexedSubscript:mi];                
        [self setValue:model forKey:[self.sortedIndex objectAtIndex:mi]];
    }
    self.loadCollectionFlag = YES;
    
    // Create Event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionAbstractLoadAfter" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Collection%@LoadAfter", self.modelClass] object:self];
    
    return self;
}

- (CollectionAbstract *)partialLoad
{
    if ([self getSize] > (self.curPage - 1) * self.pageSize
        || ([self getSize] % self.pageSize)
    ) {
        return self;
    }
    if (self.curPage > ([self getSize] / self.pageSize) + 1) {
        self.curPage = ([self getSize] / self.pageSize) + 1;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionAbstractPartialLoadBefore" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Collection%@PartialLoadBefore", self.modelClass] object:self];
    
    [[self getResource] loadCollection:self finished:@selector(partialLoadSuccess:)];
    return self;
}

- (CollectionAbstract *)partialLoadSuccess:(NSDictionary *)data
{
    // Add data to current collection
    for (NSUInteger i = 0, mi = [self getSize]; i < [[data allKeys] count]; i++, mi++) {
        NSObject *identify = [[data allKeys] objectAtIndex:i];
        if ([identify isEqual:@"total"]) {
            self.totalItems = [[data objectForKey:identify] unsignedIntegerValue];
            mi--;
            continue;
        }
        ModelAbstract *model = [[self getModel] setData:(NSDictionary *)[data objectForKey:identify]];
        [model setValue:identify forKey:@"id"];
        [self.sortedIndex setObject:[NSNumber numberWithInteger:mi] atIndexedSubscript:mi];
        [self setValue:model forKey:[self.sortedIndex objectAtIndex:mi]];
    }
    self.loadCollectionFlag = YES;
    
    // Create Event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionAbstractPartialLoadAfter" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Collection%@PartialLoadAfter", self.modelClass] object:self];
    return self;
}

- (CollectionAbstract *)clear
{
    self.loadCollectionFlag = NO;
    if (self.sortedIndex != nil) {
        [self.sortedIndex removeAllObjects];
    }
    if ([self count]) {
        [self removeAllObjects];
    }
    return self;
}

- (NSUInteger)getTotalItems
{
    return self.totalItems;
}

#pragma mark - Working with resource model
- (ModelAbstract *)getModel
{
    return [[NSClassFromString(self.modelClass) alloc] init];
}

- (NSObject <APIResource> *)getResource
{
    return (NSObject <APIResource> *)[Configuration getResource:self.modelClass];
}

@end
