//
//  Utilities.h
//  SimiPOS
//
//  Created by NGUYEN DUC CHIEN on 10/23/13.
//  Copyright (c) 2013 MARCUS Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

//Show Toast
#import "UIView+Toast.h"
static NSString * ZOToastSwitchCellId   = @"ZOToastSwitchCellId";
static NSString * ZOToastDemoCellId     = @"ZOToastDemoCellId";

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IOS7_SDK_AVAILABLE  1
#endif

@interface Utilities : NSObject

+(void)toastSuccessTitle:(NSString *)title withMessage:(NSString *)msg withView:(UIView *)inView;

+(void)toastFailTitle:(NSString *)title withMessage:(NSString *)msg withView:(UIView *)inView;

+(void)alert:(NSString *)title withMessage:(NSString *)msg;

+(void)confirm:(NSString *)title withMessage:(NSString *)msg withDelegate:(id)delegate;

// iOS Version check
+(BOOL)iOSVersion7;

// Math methods
+(NSUInteger)transformMatrix4x4:(NSUInteger)index;
+(NSUInteger)transformItems4x4:(NSUInteger)totals;


#pragma mark - Chỉ cho phép nhập số & 1 số kí tự do người dùng truyền vào
+(BOOL)maxLengthNumberWithTextField:(UITextField *)textField ReplacementString:(NSString *)string MaxLength:(int)maxLenght AndHaveCharSpecific:(NSString *)charSpecific;


#pragma  mark - Validate ki tu nhap vao chi cho phep nhap So (number)
+(BOOL)validateNumber:(UITextField *)textField currentStringInput:(NSString *)string;

#pragma  mark - Validate ki tu nhap vao chi cho phep nhap So (number) & gioi han ki tu (Maxlenght)
+(BOOL)validateNumber:(id)textInput currentStringInput:(NSString *)string maxLenght:(int)maxLenght;

#pragma mark - Export View to Image
+ (UIImage *) imageWithView:(UIView *)view;

    
@end
