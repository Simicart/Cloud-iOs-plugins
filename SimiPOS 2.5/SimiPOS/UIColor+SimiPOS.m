//
//  UIColor+SimiPOS.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/3/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "UIColor+SimiPOS.h"

@implementation UIColor (SimiPOS)

+ (UIColor *)barBackgroundColor
{
    
    NSString * barColor =[[NSUserDefaults standardUserDefaults] objectForKey:THEME_COLOR_DEFAULT];
    if(barColor){
        return  [self colorWithHexString:barColor] ;
        
    }else{
        return    [UIColor colorWithRed:0.184f green:0.722f blue:0.612f alpha:1.00f];
    }        
}

+ (UIColor *)buttonCancelColor{
    return [UIColor colorWithRed:0.322f green:0.322f blue:0.322f alpha:1.00f];
}

+ (UIColor *)buttonSubmitColor{
    return [UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.00f];
}


+ (UIColor *)buttonPressedColor
{
    return [UIColor colorWithRed:1.000 green:0.400 blue:0.000 alpha:1.000];
}

+ (UIColor *)backgroundColor
{
    return [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
}

+ (UIColor *)borderColor
{
    return [UIColor colorWithWhite:0.678 alpha:1.000];
}

+ (UIColor *)lightBorderColor
{
    return [UIColor colorWithWhite:0.88 alpha:1.0];
}

+ (UIColor *)headerColor
{
    return [UIColor grayColor];
}

+ (UIColor *)completedColor
{
    return [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1];
}


+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
