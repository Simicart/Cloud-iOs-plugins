//
//  CollectionAbstract.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSMutableDictionary.h"
#import "APIResource.h"
#import "ModelAbstract.h"

@interface CollectionAbstract : MSMutableDictionary
@property (copy, nonatomic) NSString *modelClass;

@property (nonatomic) NSUInteger pageSize;
@property (nonatomic) NSUInteger curPage;
@property (strong, nonatomic) NSMutableDictionary *conditions;

@property (nonatomic) BOOL loadCollectionFlag;
@property (nonatomic) NSUInteger totalItems;
@property (strong, nonatomic) NSMutableArray *sortedIndex;

// working with data
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)getSize;

// working with collection
- (CollectionAbstract *)load;
- (CollectionAbstract *)loadSuccess:(NSDictionary *)data;

- (CollectionAbstract *)partialLoad;
- (CollectionAbstract *)partialLoadSuccess:(NSDictionary *)data;

- (CollectionAbstract *)clear;

// get all available (both not loaded) items
- (NSUInteger)getTotalItems;

// working with resource model
- (ModelAbstract *)getModel;
- (NSObject <APIResource> *)getResource;

@end
