//
//  MSValidator.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSValidator : NSObject

+ (BOOL)validateEmail:(NSString *)email;

+ (BOOL)isEmptyString:(NSString *)aString;

@end
