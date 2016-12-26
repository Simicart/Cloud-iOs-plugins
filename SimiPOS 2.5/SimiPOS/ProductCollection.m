//
//  ProductCollection.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/18/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ProductCollection.h"
#import "Configuration.h"
#import "Product.h"

@implementation ProductCollection

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Product";
    }
    return self;
}

#pragma mark - resort collection after load
- (CollectionAbstract *)loadSuccess:(NSDictionary *)data
{
    [super loadSuccess:data];
    
    NSArray *sorted = [self.sortedIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Product *product1 = [self objectForKey:obj1];
        Product *product2 = [self objectForKey:obj2];
        return [[product1 getName] compare:[product2 getName] options:NSNumericSearch];
    }];
    [self.sortedIndex setArray:sorted];
    
    return self;
}

- (CollectionAbstract *)partialLoadSuccess:(NSDictionary *)data
{
    NSUInteger location = [self.sortedIndex count];
    [super partialLoadSuccess:data];
    NSUInteger length = [self.sortedIndex count] - location;
    NSRange partialRange = {location, length};
    
    NSArray *sorted = [[self.sortedIndex subarrayWithRange:partialRange] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Product *product1 = [self objectForKey:obj1];
        Product *product2 = [self objectForKey:obj2];
        return [[product1 getName] compare:[product2 getName] options:NSNumericSearch];
    }];
    [self.sortedIndex replaceObjectsInRange:partialRange withObjectsFromArray:sorted];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductCollectionSortAfter" object:self];
    return self;
}

#pragma mark - add filter
- (void)setCurrentCategory:(NSString *)catId
{
    if (self.conditions == nil) {
        self.conditions = [[NSMutableDictionary alloc] init];
    }
    if (catId == nil) {
        [self.conditions removeObjectForKey:@"category"];
    } else {
        [self.conditions setValue:catId forKey:@"category"];
    }
}

- (BOOL)hasCurrentCategory
{
    if (self.conditions == nil) {
        return NO;
    }
    if ([self.conditions objectForKey:@"category"] == nil) {
        return NO;
    }
    return YES;
}

- (void)setSearchTerm:(NSString *)searchTerm
{
    if (self.conditions == nil) {
        self.conditions = [[NSMutableDictionary alloc] init];
    }
    if (searchTerm == nil) {
        [self.conditions removeObjectForKey:@"name"];
        [self.conditions removeObjectForKey:@"search"];
    } else {
        NSString *likeCondition = [NSString stringWithFormat:@"%%%@%%", searchTerm];
        [self.conditions setValue:[[NSDictionary alloc] initWithObjectsAndKeys:likeCondition, @"like", nil] forKey:@"search"];
    }
}

- (BOOL)hasSearchTerm
{
    if (self.conditions == nil) {
        return NO;
    }
    if ([self.conditions objectForKey:@"name"] == nil
        && [self.conditions objectForKey:@"search"] == nil
    ) {
        return NO;
    }
    return YES;
}


#pragma mark - sort products
- (void)sortCurPageByName
{
    NSUInteger to = self.curPage * self.pageSize;
    NSUInteger from = to - self.pageSize;
    if (to >= [self getSize]) {
        to = [self getSize] - 1;
    }
    [self quickSort:from to:to];
}

- (void)quickSort:(NSUInteger)from to:(NSUInteger)to
{
    if (from >= to) {
        return;
    }
    // Divide
    NSUInteger pivot = from;
    for (NSUInteger i = from + 1; i <= to; i++) {
        if ([(NSString *)[[self objectAtIndex:i] objectForKey:@"name"] compare:(NSString *)[[self objectAtIndex:pivot] objectForKey:@"name"]] == NSOrderedAscending) {
            NSNumber *container = [self.sortedIndex objectAtIndex:i];
            [self.sortedIndex setObject:[self.sortedIndex objectAtIndex:pivot] atIndexedSubscript:i];
            [self.sortedIndex setObject:container atIndexedSubscript:pivot];
            pivot = i;
        }
    }
    // Conquer
    if (pivot - 1 > from) {
        [self quickSort:from to:pivot - 1];
    }
    if (to > pivot + 1) {
        [self quickSort:pivot+1 to:to];
    }
}

@end
