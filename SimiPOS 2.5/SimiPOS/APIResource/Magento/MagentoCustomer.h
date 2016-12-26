//
//  MagentoCustomer.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/12/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"

@interface MagentoCustomer : MagentoAbstract

- (void)deleteCustomer:(ModelAbstract *)model finished:(SEL)finishedMethod;

@end
