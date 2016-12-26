//
//  Store.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/25/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Store : ModelAbstract
@property (nonatomic) BOOL isLoadedInfo;

+ (Store *)currentStore;

- (BOOL)isLoaded;
- (void)clear;

@end
