//
//  CreditCardSwipe.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/29/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreditCardSwipe : NSObject

+ (NSDictionary *)decodeSerialized:(NSString *)ccInfoString;
+ (NSString *)getCardType:(NSString *)cardNumber;

@end
