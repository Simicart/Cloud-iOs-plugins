//
//  CategoryCollection.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"
#import "Category.h"

@interface CategoryCollection : CollectionAbstract

@property (nonatomic) NSUInteger rootCategoryId;
@property (strong, nonatomic) Category *rootCategory;

-(void)recursiveLoad:(NSDictionary *)data forRoot:(NSString *)identify;
-(Category *)addCategoryModel;

@end
