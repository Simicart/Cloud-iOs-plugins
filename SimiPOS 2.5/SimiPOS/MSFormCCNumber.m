//
//  MSFormCCNumber.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 9/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFormCCNumber.h"
#import "MSFramework.h"

@implementation MSFormCCNumber
@synthesize keyboard, optionsPopover;

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        self.inputText.clearButtonMode = UITextFieldViewModeAlways;
    }
    return self;
}

- (void)reloadFieldData
{
    if (self.ccNumber == nil) {
        self.inputText.text = [self formatCCNumber:[self.form.formData objectForKey:self.name]];
    } else {
        self.inputText.text = self.ccNumber;
    }
}

#pragma mark - Text field and select data
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.inputText.text = nil;
    [self updateFormData:nil];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (keyboard == nil) {
        keyboard = [MSNumberPad keyboard];
        [keyboard resetConfig];
        [keyboard showOn:nil atFrame:CGRectMake(0, 0, 288, 241)];
    }
    keyboard.delegate = self;
    keyboard.textField = self.inputText;
    if (optionsPopover == nil) {
        optionsPopover = [[UIPopoverController alloc] initWithContentViewController:keyboard];
        optionsPopover.popoverContentSize = CGSizeMake(288, 241);
    }
    [optionsPopover presentPopoverFromRect:self.inputText.frame inView:self permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionRight) animated:YES];
    return NO;
}

#pragma mark - keyboard
- (BOOL)numberPad:(MSNumberPad *)numberPad willChangeValue:(NSInteger)value
{
    NSString *text = [self.inputText.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (value == 11) { // Delete
        if (text && [text length]) {
            text = [text substringToIndex:([text length] - 1)];
        }
    } else {
        if ([text length] < 16) {
            text = [text stringByAppendingFormat:@"%d", (int)value];
        }
    }
    [self updateFormData:text];
    self.inputText.text = [self formatCCNumber:text];
    if ([text length] > 15) {
        [optionsPopover dismissPopoverAnimated:YES];
    }
    return NO;
}

- (BOOL)numberPadShouldDone:(MSNumberPad *)numberPad
{
    [optionsPopover dismissPopoverAnimated:YES];
    return NO;
}

#pragma mark - update form data depend on value
- (void)updateFormData:(NSString *)value
{
    if ([value length]) {
        [self.form.formData setValue:value forKey:self.name];
    } else {
        [self.form.formData removeObjectForKey:self.name];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormFieldChange" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormUpdateData" object:self.form];
}

#pragma mark - format cc number
- (NSString *)formatCCNumber:(NSString *)ccNumber
{
    if (![ccNumber isKindOfClass:[NSString class]] || ![ccNumber length]) {
        return nil;
    }
    while ([ccNumber length] % 4) {
        ccNumber = [ccNumber stringByAppendingString:@" "];
    }
    NSString *result = [ccNumber substringWithRange:NSMakeRange(0, 4)];
    for (NSInteger i = 4; i < [ccNumber length]; i+=4) {
        result = [result stringByAppendingString:@"-"];
        result = [result stringByAppendingString:[ccNumber substringWithRange:NSMakeRange(i, 4)]];
    }
    return result;
}

@end
