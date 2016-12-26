//
//  Shipping.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/21/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"
#import "Quote.h"

@class ShippingCollection;

@interface Shipping : ModelAbstract

@property (strong, nonatomic) ShippingCollection *collection;

-(Shipping *)shippingMethod;
-(BOOL)isCurrentMethod:(Shipping *)method;

// Save method
-(void)saveMethod;
-(void)saveMethodSuccess;

@end
