//
//  OrderCollection.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/16/13.
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
