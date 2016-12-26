//
//  NSDictionary+MutableDeepCopy.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MutableDeepCopy)

- (NSMutableDictionary *)mutableDeepCopy;

@end
