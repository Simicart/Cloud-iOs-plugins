//
//  ProductCollection.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/18/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"

@interface ProductCollection : CollectionAbstract

- (void)sortCurPageByName;
- (void)quickSort:(NSUInteger)from to:(NSUInteger)to;

#pragma mark - Category and search
- (void)setCurrentCategory:(NSString *)catId;
- (BOOL)hasCurrentCategory;
- (void)setSearchTerm:(NSString *)searchTerm;
- (BOOL)hasSearchTerm;

@end
