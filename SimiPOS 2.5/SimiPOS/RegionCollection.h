//
//  RegionCollection.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/10/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"

@interface RegionCollection : CollectionAbstract

@property (copy, nonatomic) NSString *countryCode;

- (void)setCountry:(NSString *)country;

- (NSDictionary *)regionAsDictionary;

@end
