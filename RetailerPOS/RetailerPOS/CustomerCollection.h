//
//  CustomerCollection.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"

@interface CustomerCollection : CollectionAbstract
@property (copy, nonatomic) NSString *searchTerm;

-(BOOL)hasSearchTerm;

@end
