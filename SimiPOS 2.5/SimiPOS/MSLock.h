//
//  MSLock.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/6/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSLock : NSObject

+ (NSMutableDictionary *)lockObjects;

+ (void)wait:(NSObject *)object;
+ (void)release:(NSObject *)object;

@end
