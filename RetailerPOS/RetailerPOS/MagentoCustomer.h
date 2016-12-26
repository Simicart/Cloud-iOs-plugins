//
//  MagentoCustomer.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"

@interface MagentoCustomer : MagentoAbstract

- (void)deleteCustomer:(ModelAbstract *)model finished:(SEL)finishedMethod;

@end
