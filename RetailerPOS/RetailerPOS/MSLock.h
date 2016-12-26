//
//  MSLock.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/6/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSLock : NSObject

+ (NSMutableDictionary *)lockObjects;

+ (void)wait:(NSObject *)object;
+ (void)release:(NSObject *)object;

@end
