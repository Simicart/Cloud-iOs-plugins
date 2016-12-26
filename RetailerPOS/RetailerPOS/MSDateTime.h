//
//  MSDateTime.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/23/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDateTime : NSObject

+ (NSString *)formatDateTime:(NSString *)datetime;
+ (NSString *)formatDate:(NSString *)datetime;
+ (NSString *)formatTime:(NSString *)datetime;

@end
