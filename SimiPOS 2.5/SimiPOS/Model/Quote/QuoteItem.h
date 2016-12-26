//
//  QuoteItem.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelAbstract.h"

@class Product;

@interface QuoteItem : ModelAbstract

@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) NSMutableDictionary *options;

-(CGFloat)getQty;

-(NSString *)getName;
-(NSString *)getOptionsLabel;
-(NSString *)getOptionLabel:(NSDictionary *)option;

-(NSNumber *)getRegularPrice;
-(NSNumber *)getPrice;
-(BOOL)hasSpecialPrice;

@end
