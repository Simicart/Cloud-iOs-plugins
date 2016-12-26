//
//  CreditCardSwipe.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/29/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CreditCardSwipe.h"
#import "CreditCard-Validator.h"

@interface CreditCardSwipe ()
+ (NSString *)trim:(NSString *)aString;
@end

@implementation CreditCardSwipe

+ (NSDictionary *)decodeSerialized:(NSString *)ccInfoString
{
    NSMutableDictionary *ccInfo = [[NSMutableDictionary alloc] init];
    
    // Refine info string
    NSString *trackString = [ccInfoString substringFromIndex:1];
    trackString = [trackString substringToIndex:trackString.length - 1];
    
    NSRange range = [trackString rangeOfString:@"^"];
    if (range.location != NSNotFound) {
        // Track 1 Decode
        NSArray *trackInfo = [trackString componentsSeparatedByString:@"^"];
        if ([trackInfo count] > 2) {
            [ccInfo setValue:[[trackInfo objectAtIndex:0] substringFromIndex:1] forKey:@"cc_number"];
            
            NSString *owner = [self trim:[trackInfo objectAtIndex:1]];
            NSArray *ownerArr = [owner componentsSeparatedByString:@"/"];
            if ([ownerArr count] > 1) {
                owner = [NSString stringWithFormat:@"%@ %@", [ownerArr objectAtIndex:1], [ownerArr objectAtIndex:0]];
            }
            [ccInfo setValue:owner forKey:@"cc_owner"];
            
            NSString *month = [[trackInfo objectAtIndex:2] substringWithRange:NSRangeFromString(@"{2,2}")];
            [ccInfo setValue:[NSNumber numberWithInt:[month intValue]] forKey:@"cc_exp_month"];
            
            NSString *year = [NSString stringWithFormat:@"20%@", [[trackInfo objectAtIndex:2] substringToIndex:2]];
            [ccInfo setValue:[NSNumber numberWithInt:[year intValue]] forKey:@"cc_exp_year"];
            
            [ccInfo setValue:[self getCardType:[ccInfo objectForKey:@"cc_number"]] forKey:@"cc_type"];
            
            NSString *cvvStr;
            if ([[ccInfo objectForKey:@"cc_type"] isEqualToString:@"AE"]) {
                cvvStr = [[trackInfo objectAtIndex:2] substringWithRange:NSRangeFromString(@"{22,4}")];
            } else if ([[ccInfo objectForKey:@"cc_type"] isEqualToString:@""]) {
                cvvStr = @"";
            } else {
                cvvStr = [[trackInfo objectAtIndex:2] substringWithRange:NSRangeFromString(@"{22,3}")];
            }
            [ccInfo setValue:cvvStr forKey:@"cc_cid"];
        }
        return ccInfo;
    }
    
    range = [trackString rangeOfString:@"="];
    if (range.location != NSNotFound) {
        // Track 2 decode
        NSArray *trackInfo = [trackString componentsSeparatedByString:@"="];
        if ([trackInfo count] != 2) {
            return ccInfo;
        }
        [ccInfo setValue:[trackInfo objectAtIndex:0] forKey:@"cc_number"];
        
        NSString *month = [[trackInfo objectAtIndex:1] substringWithRange:NSRangeFromString(@"{2,2}")];
        [ccInfo setValue:[NSNumber numberWithInt:[month intValue]] forKey:@"cc_exp_month"];
        
        NSString *year = [NSString stringWithFormat:@"20%@", [[trackInfo objectAtIndex:1] substringToIndex:2]];
        [ccInfo setValue:[NSNumber numberWithInt:[year intValue]] forKey:@"cc_exp_year"];
        
        [ccInfo setValue:[self getCardType:[ccInfo objectForKey:@"cc_number"]] forKey:@"cc_type"];
        
        NSString *cvvStr;
        if ([[ccInfo objectForKey:@"cc_type"] isEqualToString:@"AE"]) {
            cvvStr = [[trackInfo objectAtIndex:1] substringWithRange:NSRangeFromString(@"{12,4}")];
        } else if ([[ccInfo objectForKey:@"cc_type"] isEqualToString:@""]) {
            cvvStr = @"";
        } else {
            cvvStr = [[trackInfo objectAtIndex:1] substringWithRange:NSRangeFromString(@"{12,3}")];
        }
        [ccInfo setValue:cvvStr forKey:@"cc_cid"];
    }
    
    return ccInfo;
}

+ (NSString *)getCardType:(NSString *)cardNumber
{
    CreditCardBrand brand = [CreditCard_Validator checkCardBrandWithNumber:cardNumber];
    switch (brand) {
        case CreditCardBrandVisa:
            return @"VI";
        case CreditCardBrandAmex:
            return @"AE";
        case CreditCardBrandMasterCard:
            return @"MC";
        case CreditCardBrandDiscover:
            return @"DI";
        case CreditCardBrandDinersClub:
            return @"DC";
        case CreditCardBrandUnknown:
        default:
            return @"";
    }
}

+ (NSString *)trim:(NSString *)aString
{
    return [aString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]];
}

@end
