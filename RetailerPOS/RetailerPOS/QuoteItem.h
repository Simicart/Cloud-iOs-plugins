//
//  QuoteItem.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/9/2016.
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

-(void)increaseQty;

@end
