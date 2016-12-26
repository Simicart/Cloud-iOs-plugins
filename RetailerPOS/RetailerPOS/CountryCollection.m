//
//  CountryCollection.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CountryCollection.h"

@implementation CountryCollection

-(id)init
{
    if (self = [super init]) {
        self.modelClass = @"Country";
    }
    return self;
}

+ (NSDictionary *)allCountryAsDictionary
{
    NSMutableDictionary *countryDic = [[NSMutableDictionary alloc] init];
    for (NSString *code in [NSLocale ISOCountryCodes]) {
        NSString *identifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCountryCode: code}];
        NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
        if (countryName) {
            countryDic[code] = countryName;
        }
    }
    return countryDic;
}

@end
