//
//  MagentoUser.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"

@interface MagentoUser : MagentoAbstract

- (void)deleteUser:(ModelAbstract *)user finished:(SEL)finishedMethod;

@end
