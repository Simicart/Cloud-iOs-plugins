//
//  MSFormCCDate.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 9/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFormCCDate.h"
#import "MSFramework.h"

@interface MSFormCCDate()
@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UIPopoverController *optionsPopover;
@property (strong, nonatomic) NSString *yName;
@end

@implementation MSFormCCDate
@synthesize inputText;
@synthesize keyboard, optionsPopover, yName;

#pragma mark - Abstract methods
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
        
        // Year Name
        self.yName = [data objectForKey:@"name1"];
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
    NSString *month = [self.form.formData objectForKey:self.name];
    NSString *year = [self.form.formData objectForKey:self.yName];
    if (month && year && [month isKindOfClass:[NSString class]] && [year isKindOfClass:[NSString class]]) {
        while ([month length] < 2) {
            month = [@"0" stringByAppendingString:month];
        }
        year = [year substringFromIndex:2];
        while ([year length] < 2) {
            year = [@"0" stringByAppendingString:year];
        }
        self.inputText.text = [NSString stringWithFormat:@"%@/%@", month, year];
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
    [optionsPopover presentPopoverFromRect:self.inputText.frame inView:self permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionLeft) animated:YES];
    return NO;
}

#pragma mark - keyboard
- (BOOL)numberPad:(MSNumberPad *)numberPad willChangeValue:(NSInteger)value
{
    NSString *text = inputText.text;
    if (value == 11) { // Delete
        if (text && [text length]) {
            if ([text length] == 3) {
                text = [text substringToIndex:([text length] -2)];
            } else {
                text = [text substringToIndex:([text length] - 1)];
            }
            inputText.text = text;
        }
    } else {
        if ([text length] < 5) {
            text = [NSString stringWithFormat:@"%@%d", text, (int)value];
        }
        if ([text length] == 2) {
            text = [text stringByAppendingString:@"/"];
        }
        inputText.text = text;
    }
    [self updateFormData:text];
    if ([text length] > 4) {
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
    if ([value length] < 5) {
        [self.form.formData removeObjectForKey:self.name];
        [self.form.formData removeObjectForKey:self.yName];
    } else {
        NSArray *values = [value componentsSeparatedByString:@"/"];
        [self.form.formData setValue:values[0] forKey:self.name];
        [self.form.formData setValue:[@"20" stringByAppendingString:values[1]] forKey:self.yName];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormFieldChange" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormUpdateData" object:self.form];
}

@end
