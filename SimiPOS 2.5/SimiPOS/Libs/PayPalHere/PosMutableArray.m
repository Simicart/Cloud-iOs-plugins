

#import "PosMutableArray.h"

@implementation PosMutableArray

- (id)init
{
    self = [super init];
    if (self) {
        mutableArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems{
    self = [super initWithCapacity:0];
    if (self) {
        mutableArray = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array{
    self = [super init];
    if (self) {
        mutableArray = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}

- (NSMutableArray *)data{
    return mutableArray;
}

- (id)objectAtIndex:(NSUInteger)index{
    if ([mutableArray count] <= index) {
        return nil;
    }
    return [mutableArray objectAtIndex:index];
}

- (NSUInteger)count{
    return [mutableArray count];
}

- (void)addObject:(id)anObject{
    [mutableArray addObject:anObject];
}

- (void)addObjectsFromArray:(NSArray *)otherArray{
    [mutableArray addObjectsFromArray:otherArray];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    [mutableArray insertObject:anObject atIndex:index];
}

- (void)removeObject:(id)anObject{
    [mutableArray removeObject:anObject];
}

- (void)removeAllObjects{
    [mutableArray removeAllObjects];
}

- (void)removeLastObject{
    [mutableArray removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    [mutableArray replaceObjectAtIndex:index withObject:anObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index{
    [mutableArray removeObjectAtIndex:index];
}

@end
