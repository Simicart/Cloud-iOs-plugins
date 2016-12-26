

#import <Foundation/Foundation.h>

@interface PosMutableArray : NSMutableArray{
    NSMutableArray *mutableArray;
}

- (id)init;
- (NSUInteger)count;
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeLastObject;
- (void)removeAllObjects;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSMutableArray *)data;

@end
