//
//  MSDateTime.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDateTime : NSObject

+ (NSString *)formatDateTime:(NSString *)datetime;
+ (NSString *)formatDate:(NSString *)datetime;
+ (NSString *)formatTime:(NSString *)datetime;

@end
