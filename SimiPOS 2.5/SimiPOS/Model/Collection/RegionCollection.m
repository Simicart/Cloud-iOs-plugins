//
//  RegionCollection.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/10/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "RegionCollection.h"

@implementation RegionCollection
@synthesize countryCode;

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Region";
    }
    return self;
}

- (void)setCountry:(NSString *)country
{
    if (country == nil) {
        if (countryCode != nil) {
            countryCode = country;
        }
        self.loadCollectionFlag = YES;
    } else if (![country isEqualToString:countryCode]) {
        countryCode = country;
        [self clear];
    }
}

- (NSDictionary *)regionAsDictionary
{
    NSMutableDictionary *regions = [NSMutableDictionary new];
    for (NSUInteger i = 0; i < [self getSize]; i++) {
        ModelAbstract *region = [self objectAtIndex:i];
        regions[[region getId]] = [region objectForKey:@"name"];
    }
    return regions;
}

#pragma mark - override abstract method
- (CollectionAbstract *)load
{
    if (self.countryCode == nil) {
        return self;
    }
    return [super load];
}

@end
