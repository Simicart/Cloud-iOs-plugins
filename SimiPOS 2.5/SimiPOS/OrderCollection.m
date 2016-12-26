//
//  OrderCollection.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/16/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "OrderCollection.h"

@implementation OrderCollection
@synthesize searchTerm = _searchTerm;

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Order";
    }
    return self;
}

#pragma mark - resort collection after load
- (CollectionAbstract *)loadSuccess:(NSDictionary *)data
{
    [super loadSuccess:data];
    
    NSArray *sorted = [self.sortedIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ModelAbstract *order1 = [self objectForKey:obj1];
        ModelAbstract *order2 = [self objectForKey:obj2];
        return [[order2 getId] compare:[order1 getId] options:NSNumericSearch];
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
        ModelAbstract *order1 = [self objectForKey:obj1];
        ModelAbstract *order2 = [self objectForKey:obj2];
        return [[order2 getId] compare:[order1 getId] options:NSNumericSearch];
    }];
    [self.sortedIndex replaceObjectsInRange:partialRange withObjectsFromArray:sorted];
    
    return self;
}


-(void)removeOrder:(Order *)order{
   // NSLog(@"order count before delete:%d",self.count);
    NSString * incrementID1 =[order objectForKey:@"increment_id"];
    for (NSUInteger i = 0; i < [self allKeys].count; i++) {
        NSObject *identify = [[self allKeys] objectAtIndex:i];
        id object = [self objectForKey:identify];
        if([object isKindOfClass:[Order class]]){
            NSString * incrementID2 =[(Order*)object getIncrementId];
            if(incrementID2 && [incrementID2 isEqualToString:incrementID1]){
                [self removeObjectForKey:identify];
               // NSLog(@"order count before delete:%d",self.count);
                return;
            }
        }
    }
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
