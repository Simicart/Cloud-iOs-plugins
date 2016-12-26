//
//  Store.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/25/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Store : ModelAbstract

+ (Store *)currentStore;

- (BOOL)isLoaded;
- (void)clear;

@end
