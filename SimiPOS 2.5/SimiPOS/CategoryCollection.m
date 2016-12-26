//
//  CategoryCollection.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CategoryCollection.h"

@implementation CategoryCollection
@synthesize rootCategoryId = _rootCategoryId;
@synthesize rootCategory = _rootCategory;

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Category";
    }
    return self;
}

- (CollectionAbstract *)loadSuccess:(NSDictionary *)data
{
    [self clear];
    if (self.rootCategory == nil) {
        self.rootCategory = (Category *)[self getModel];
    }
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqual:@"root"]) {
            [self.rootCategory setValue:obj forKey:@"id"];
        } else if ([key isEqual:@"level"]) {
            [self.rootCategory setValue:obj forKey:@"level"];
            self.rootCategoryId = [self.rootCategory getLevel];
        } else if ([key isEqual:@"name"]) {
            [self.rootCategory setValue:obj forKey:@"name"];
        } else {
            [self recursiveLoad:obj forRoot:key];
        }
    }];
    self.loadCollectionFlag = YES;
    
    // Create Event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionAbstractLoadAfter" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"CollectionCategoryLoadAfter"] object:self];
    
    return self;
}

- (void)recursiveLoad:(NSDictionary *)data forRoot:(NSString *)identify
{
    // Add root model
    Category *rootCategory = [self addCategoryModel];
    [rootCategory setValue:identify forKey:@"id"];
    
    // Init root and children model
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqual:@"level"]) {
            [rootCategory setValue:obj forKey:@"level"];
        } else if ([key isEqual:@"name"]) {
            [rootCategory setValue:obj forKey:@"name"];
        } else {
            [self recursiveLoad:obj forRoot:key];
        }
    }];
}

- (Category *)addCategoryModel
{
    Category *model = (Category *)[self getModel];
    NSUInteger index = [self.sortedIndex count];
    [self.sortedIndex setObject:[NSNumber numberWithUnsignedInteger:index] atIndexedSubscript:index];
    [self setValue:model forKey:[self.sortedIndex objectAtIndex:index]];
    return model;
}

@end
