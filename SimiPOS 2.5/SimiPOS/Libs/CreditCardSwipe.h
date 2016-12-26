//
//  CreditCardSwipe.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/29/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreditCardSwipe : NSObject

+ (NSDictionary *)decodeSerialized:(NSString *)ccInfoString;
+ (NSString *)getCardType:(NSString *)cardNumber;

@end
