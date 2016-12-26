//
//  MSFormText.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormText.h"
#import "MSFormRow.h"
#import "MSForm.h"
#import "MSFormCCNumber.h"

@implementation MSFormText
@synthesize inputText;

#pragma mark - Abstract methods
- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        // Init input text element
        self.inputText = [[UITextField alloc] init];
        self.inputText.delegate = self;
        self.inputText.clearsOnBeginEditing = NO;
        self.inputText.returnKeyType = UIReturnKeyNext;
        
        [self.inputText addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
        [self.inputText addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // Configuration Input
        if (self.required) {
            self.inputText.placeholder = [NSString stringWithFormat:@"%@ (%@)", self.title, NSLocalizedString(@"Required", nil)];
        } else {
            self.inputText.placeholder = self.title;
        }
        self.inputText.font = [UIFont systemFontOfSize:18];
        self.inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
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
}

#pragma mark - Input text
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateFormData:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return ![self moveToNextInputText];
}

- (BOOL)moveToNextInputText
{
    BOOL nextField = NO;
    for (MSFormAbstract *field in self.form.formFields) {
        if ([field isKindOfClass:[MSFormRow class]]) {
            for (MSFormAbstract *subField in [(MSFormRow *)field childFields]) {
                if ([subField isEqual:self]) {
                    nextField = YES;
                    continue;
                }
                if (nextField && [subField isKindOfClass:[MSFormText class]] && ![subField isKindOfClass:[MSFormCCNumber class]]) {
                    [(MSFormText *)subField forcusInput];
                    return nextField;
                }
            }
            continue;
        }
        if ([field isEqual:self]) {
            nextField = YES;
            continue;
        }
        if (nextField && [field isKindOfClass:[MSFormText class]] && ![field isKindOfClass:[MSFormCCNumber class]]) {
            [(MSFormText *)field forcusInput];
            return nextField;
        }
    }
    return NO;
}

- (void)forcusInput
{
    NSUInteger row;
    if ([[self superview] isKindOfClass:[MSFormRow class]]) {
        row = [self.form.formFields indexOfObject:[self superview]];
    } else {
        row = [self.form.formFields indexOfObject:self];
    }
    [self.form scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.inputText performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25];
}

@end
