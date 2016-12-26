//
//  Shipping.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/21/13.
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
