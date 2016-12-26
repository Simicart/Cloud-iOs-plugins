//
//  QuoteItem.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "QuoteItem.h"
#import "Product.h"

@implementation QuoteItem

@synthesize product = _product;
@synthesize options = _options;

- (CGFloat)getQty
{
    // Check qty from options
    if (self.options != nil && [self.options objectForKey:@"qty"] != nil) {
        return [[self.options objectForKey:@"qty"] floatValue];
    }
    
    if([self objectForKey:@"qty"] ==nil){
        return 0;
    }
    
    return [[self objectForKey:@"qty"] floatValue];
}

- (NSString *)getName
{
    if ([self objectForKey:@"name"] != nil) {
        return [self objectForKey:@"name"];
    }
    return [self.product getName];
}

- (NSString *)getOptionsLabel
{
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    if (![self.product hasOptions]) {
        return nil;
    }
    //Ravi
    NSMutableArray *optionList = [NSMutableArray new];
    if ([[self.product objectForKey:@"options"] isKindOfClass:[NSArray class]]) {
        [optionList addObjectsFromArray:[self.product objectForKey:@"options"]];
    }
//    for (NSDictionary *option in [self.product getOptions]) {
    for (NSDictionary *option in optionList) {
    //End
        NSString *optionLabel = [self getOptionLabel:option];
        if (optionLabel != nil) {
            [labels addObject:optionLabel];
        }
    }
    if ([labels count]) {
        return [labels componentsJoinedByString:@", "];
    }
    return nil;
}

- (NSString *)getOptionLabel:(NSDictionary *)option
{
    id selectedOption = [self.options objectForKey:[option objectForKey:@"name"]];
    if (selectedOption == nil) {
        return nil;
    }
    if ([[option objectForKey:@"group"] isEqualToString:@"date"]
        || [[option objectForKey:@"group"] isEqualToString:@"text"]
    ) {
        if ([selectedOption isKindOfClass:[NSString class]]) {
            return selectedOption;
        }
        NSString *result;
        if ([selectedOption objectForKey:@"day"]) {
            result = [NSString stringWithFormat:@"%@-%@-%@", [selectedOption objectForKey:@"year"], [selectedOption objectForKey:@"month"], [selectedOption objectForKey:@"day"]];
        }
        if ([selectedOption objectForKey:@"hour"]) {
            if (result) {
                result = [result stringByAppendingString:[NSString stringWithFormat:@" %@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]]];
            } else {
                result = [NSString stringWithFormat:@"%@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]];
            }
        }
        return result;
    }
    NSDictionary *optionValues = [option objectForKey:@"values"];
    if ([selectedOption isKindOfClass:[NSArray class]]) {
        NSMutableArray *optionTitles = [[NSMutableArray alloc] init];
        for (id valueId in selectedOption) {
            [optionTitles addObject:[[optionValues objectForKey:valueId] objectForKey:@"title"]];
        }
        return [optionTitles componentsJoinedByString:@", "];
    }
    if ([optionValues count]) {
        
        if([selectedOption isKindOfClass:[NSNumber class]]){
            
             NSString * keyOption =[NSString stringWithFormat:@"%@",selectedOption];
             return [[optionValues objectForKey:keyOption] objectForKey:@"title"];
        }
        return [[optionValues objectForKey:selectedOption] objectForKey:@"title"];
    }
    return selectedOption;
}

#pragma mark - item prices
-(NSNumber *)getRegularPrice
{
    id regularPrice = [self objectForKey:@"regular_price"];
    if (regularPrice == nil
        || [regularPrice isKindOfClass:[NSNull class]]
    ) {
        return [self getPrice];
    }
    if ([regularPrice isKindOfClass:[NSNumber class]]) {
        return regularPrice;
    }
    return [NSNumber numberWithDouble:[regularPrice doubleValue]];
}

-(NSNumber *)getPrice
{
    id price = [self objectForKey:@"price"];
    if ([price isKindOfClass:[NSNumber class]] || price == nil) {
        return price;
    }
    return [NSNumber numberWithDouble:[price doubleValue]];
}

-(BOOL)hasSpecialPrice
{
    id regularPrice = [self objectForKey:@"custom_price"];
    if (regularPrice == nil
        || [regularPrice isKindOfClass:[NSNull class]]
        ) {
        return NO;
    }
    return YES;
}

@end
