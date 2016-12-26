//
//  MagentoProduct.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/18/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
@class Product;

@interface MagentoProduct : MagentoAbstract

-(NSMutableArray *)loadOptions:(Product *)product;

- (void)loadDetail:(Product *)product withId:(NSObject *)identify finished:(SEL)finishedMethod;

@end
