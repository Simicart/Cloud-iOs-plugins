//
//  MagentoAccount.h
//  RetailerPOS
//
//  Created by Marcus on 2/3/16.
//  Copyright (c) 2016  Nguyen Duc Chien. All rights reserved.
//

#import "Account.h"
#import "MagentoAbstract.h"

@interface MagentoAccount : MagentoAbstract

- (void)authorize:(Account *)account;

@end
