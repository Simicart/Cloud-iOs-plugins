//
//  MSFormCvv.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 9/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFormCvv.h"
#import "MSFramework.h"

@interface MSFormCvv()
@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UIPopoverController *optionsPopover;
@end

@implementation MSFormCvv
@synthesize inputText, keyboard, optionsPopover;

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        // Init Input Text View
        self.inputText = [[UITextField alloc] init];
        self.inputText.delegate = self;
        self.inputText.clearsOnBeginEditing = NO;
        
        self.inputText.placeholder = self.title;
        self.inputText.font = [UIFont systemFontOfSize:18];
        self.inputText.clearButtonMode = UITextFieldViewModeAlways;
        [self.inputText setSecureTextEntry:YES];
    }
    return self;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    // Add Input Text
    [self addSubview:self.inputText];
    self.inputText.frame = CGRectMake(10, 0, self.bounds.size.width - 20, 24);
    self.inputText.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y);
}

- (void)reloadFieldData
{
    self.inputText.text = [self.form.formData objectForKey:self.name];
    if (![self.inputText.text isKindOfClass:[NSString class]]) {
        self.inputText.text = nil;
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
        //Ravi fixbug keyboard
//        keyboard = [MSNumberPad keyboard];
        keyboard = [[MSNumberPad alloc] init];
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
    NSString *text = inputText.text;
    if (value == 11) { // Delete
        if (text && [text length]) {
            text = [text substringToIndex:([text length] - 1)];
            inputText.text = text;
        }
    } else {
        if ([text length] < 4) {
            text = [NSString stringWithFormat:@"%@%d", text, (int)value];
        }
        inputText.text = text;
    }
    [self updateFormData:text];
    if ([text length] > 3) {
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

@end
