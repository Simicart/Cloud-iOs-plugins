//
//  MagentoProduct.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/18/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
@class Product;

@interface MagentoProduct : MagentoAbstract

-(NSMutableArray *)loadOptions:(Product *)product;

- (void)loadDetail:(Product *)product withId:(NSObject *)identify finished:(SEL)finishedMethod;

@end
