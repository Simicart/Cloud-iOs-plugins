//
//  Price.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/31/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Price.h"
#import "Configuration.h"

@interface Price()
@property (nonatomic) BOOL isLoadedFormat;
@end

@implementation Price
@synthesize isLoadedFormat;

-(id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Price";
        self.isLoadedFormat = NO;
    }
    return self;
}

-(void)loadSuccess
{
    self.isLoadedFormat = YES;
    [super loadSuccess];
}

#pragma mark - price utilities
+(Price *)instance
{
    return (Price *)[Configuration getSingleton:@"Price"];
}

+(NSUInteger)precision
{
    Price *instance = [Price instance];
    if (!instance.isLoadedFormat) {
        [instance load:nil];
        return 2;
    }
    return [[instance objectForKey:@"precision"] unsignedIntegerValue];
}

#pragma mark - instance format price method
+(NSString *)format:(NSNumber *)price
{
    Price *instance = (Price *)[Configuration getSingleton:@"Price"];
    return [instance formatPrice:[price doubleValue]];
}

-(NSString *)formatPrice:(long double)price
{
    if (!self.isLoadedFormat) {
        [self load:nil];
        return [NSString stringWithFormat:@"$%.2f", (float)price];
    }
    BOOL signature = NO;
    if (price < 0) {
        price = -price;
        signature = YES;
    }
    // format price
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    long long iPrice;
    NSInteger i;
    
    NSInteger precision = [[self objectForKey:@"precision"] unsignedIntegerValue];
    if (precision > 0) {
        iPrice = (long long)roundl((price - floorl(price)) * powl(10, precision));
        for (i = 0; i < precision; i++) {
            [stack addObject:[NSString stringWithFormat:@"%lld", iPrice % 10]];
            iPrice /= 10;
        }
        [stack addObject:[self objectForKey:@"decimalSymbol"]];
    } else {
        price = roundl(price);
    }
    
    iPrice = (long long)price;
    if (iPrice) {
        NSInteger groupLength = [[self objectForKey:@"groupLength"] unsignedIntegerValue];
        i = 0;
        while (iPrice) {
            if (i == groupLength) {
                i = 0;
                [stack addObject:[self objectForKey:@"groupSymbol"]];
            }
            [stack addObject:[NSString stringWithFormat:@"%lld", iPrice % 10]];
            iPrice /= 10;
            i++;
        }
    } else {
        [stack addObject:@"0"];
    }
    
    NSMutableString *priceString = [[NSMutableString alloc] init];
    for (i = [stack count]; i > 0; ) {
        [priceString appendString:[stack objectAtIndex:--i]];
    }
    NSString *priceStr = [NSString stringWithFormat:[self objectForKey:@"pattern"], [priceString UTF8String]];
    if (signature) {
        return [NSString stringWithFormat:@"- %@", priceStr];
    }
    return priceStr;
}

@end
