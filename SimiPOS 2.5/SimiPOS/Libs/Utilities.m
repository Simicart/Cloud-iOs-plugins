//
//  Utilities.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(void)toastSuccessTitle:(NSString *)title withMessage:(NSString *)msg withView:(UIView *)inView{
    
    //CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    //style.messageColor = [UIColor whiteColor];
    
    [inView makeToast:msg  duration:2.0
             position:CSToastPositionCenter
                title:title
                image:[UIImage imageNamed:@"ok.png"]
                style:nil
           completion:nil];
    
}

+(void)toastFailTitle:(NSString *)title withMessage:(NSString *)msg withView:(UIView *)inView{
    
    [inView makeToast:msg  duration:2.0
             position:CSToastPositionCenter
                title:title
                image:[UIImage imageNamed:@"error.png"]
                style:nil
           completion:nil];
}

+(void)alert:(NSString *)title withMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert show];
}

+(void)confirm:(NSString *)title withMessage:(NSString *)msg withDelegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
}

#pragma mark - ios Version
+ (BOOL)iOSVersion7
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

#pragma mark - math methods
+(NSUInteger)transformMatrix4x4:(NSUInteger)index
{
    NSUInteger x = index / 4;
    NSUInteger y = index % 4;
    return y * 4 + x;
}

+(NSUInteger)transformItems4x4:(NSUInteger)totals
{
    if (totals < 1) {
        return 0;
    }
    if (totals > 4) {
        return 16;
    }
    return totals * 4 - 3;
}

#pragma mark - Chỉ cho phép nhập số & 1 số kí tự do người dùng truyền vào
+(BOOL)maxLengthNumberWithTextField:(UITextField *)textField ReplacementString:(NSString *)string MaxLength:(int)maxLenght AndHaveCharSpecific:(NSString *)charSpecific{
    
    if([string isEqualToString:@""]){
        return YES;
    }
    
    if(textField.text.length >=maxLenght){
        return NO;
    }
    
    if([string isEqualToString:charSpecific]){
        return YES;
    }
    
    return [self validateNumber:textField currentStringInput:string];
    
}


#pragma  mark - Validate ki tu nhap vao chi cho phep nhap So (number) & gioi han ki tu (Maxlenght)
+(BOOL)validateNumber:(UITextField *)textField currentStringInput:(NSString *)string{
    //Nut xoa trai
    if([string isEqualToString:@""]){
        return YES;
    }
    NSUInteger lengthOfString = string.length;
    for (NSInteger index = 0; index < lengthOfString; index++) {
        unichar character = [string characterAtIndex:index];
        
        if(character ==46) return YES; // Cho phép gõ dấu chấm .
        if(character ==127) return YES; // Cho phép  DEL
        if(character ==32) return YES; // Cho phép  Khoang trong
        
        
        if (character < 48) return NO; // 48 unichar for 0
        if (character > 57) return NO; // 57 unichar for 9
    }
    
    return YES;
}

#pragma  mark - Validate ki tu nhap vao chi cho phep nhap So (number) & gioi han ki tu (Maxlenght)
+(BOOL)validateNumber:(id)textInput currentStringInput:(NSString *)string maxLenght:(int)maxLenght{
    
    //Nut xoa trai
    if([string isEqualToString:@""]){
        return YES;
    }
    
    if([textInput isKindOfClass:[UITextField class]]){
        
        UITextField * textField = (UITextField *) textInput;
        //Kiem tra do dai
        if (textField.text.length >= maxLenght){
            return NO;
        }
        
    }else  if([textInput isKindOfClass:[UITextView class]]){
        
        UITextView * textView = (UITextView *) textInput;
        
        if (textView.text.length >=maxLenght){
            return NO;
        }
    }
    
    //Kiem tra ki tu nhap vao
    NSUInteger lengthOfString = string.length;
    for (NSInteger index = 0; index < lengthOfString; index++) {
        unichar character = [string characterAtIndex:index];
        if(character ==46) return YES; // Cho phép gõ dấu chấm .
        if(character ==127) return YES; // Cho phép  DEL
        if(character ==32) return YES; // Cho phép  Khoang trong
        
        
        if (character < 48) return NO; // 48 unichar for 0
        if (character > 57) return NO; // 57 unichar for 9
    }
    
    return YES;
}

#pragma mark - Export View to Image
+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
