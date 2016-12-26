//
//  CustomerCollection.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/12/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"

@interface CustomerCollection : CollectionAbstract
@property (copy, nonatomic) NSString *searchTerm;

-(BOOL)hasSearchTerm;

@end
