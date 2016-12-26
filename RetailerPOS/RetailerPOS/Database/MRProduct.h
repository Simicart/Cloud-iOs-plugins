//
//  MRProduct.h
//  RetailerPOS
//
//  Created by mac on 4/13/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Product.h"

@interface MRProduct : NSManagedObject

@property (nonatomic, retain) NSString *product_id;
@property (nonatomic, retain) NSString *sku;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *has_option;
@property (nonatomic, retain) NSString *data_index;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, retain) NSString *sort_index;
@property (nonatomic, retain) NSString *cat_ids;

-(Product *)convertModelProduct;

+(void)syncData:(NSDictionary *)products;

-(NSString *)getPrice;

@end

