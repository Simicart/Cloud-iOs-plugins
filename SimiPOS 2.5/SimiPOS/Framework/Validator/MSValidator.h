//
//  MSValidator.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/16/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSValidator : NSObject

+ (BOOL)validateEmail:(NSString *)email;

+ (BOOL)isEmptyString:(NSString *)aString;

@end
