//
//  OrderCollection.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"
#import "Order.h"

@interface OrderCollection : CollectionAbstract

@property (copy, nonatomic) NSString *searchTerm;
@property (assign, nonatomic) BOOL isHoldOrder ;

-(BOOL)hasSearchTerm;

-(void)removeOrder:(Order *)order;


@end
