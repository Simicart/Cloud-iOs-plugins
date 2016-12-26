//
//  RegionCollection.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"

@interface RegionCollection : CollectionAbstract

@property (copy, nonatomic) NSString *countryCode;

- (void)setCountry:(NSString *)country;

- (NSDictionary *)regionAsDictionary;

@end
