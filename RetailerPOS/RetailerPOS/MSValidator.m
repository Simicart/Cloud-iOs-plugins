//
//  MSValidator.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 13/04/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSValidator.h"

@implementation MSValidator

+ (BOOL)validateEmail:(NSString *)email
{
    if (email == nil || ![email isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

+ (BOOL)isEmptyString:(NSString *)aString
{
    if (aString == nil || ![aString isKindOfClass:[NSString class]] || [aString isEqualToString:@""] || [aString isEqualToString:@" "]) {
        return YES;
    }
    return NO;
}

@end
