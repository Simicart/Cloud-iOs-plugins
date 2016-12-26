//
//  MSFormTextarea.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormTextarea.h"
#import "MSForm.h"

@implementation MSFormTextarea
@synthesize textInput;

#pragma mark - abstract methods
- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        self.textInput = [[UITextView alloc] init];
        self.textInput.delegate = self;
        self.textInput.returnKeyType = UIReturnKeyNext;
        self.textInput.font = [UIFont systemFontOfSize:18];
        
        self.inputText.clearButtonMode = UITextFieldViewModeNever;
    }
    return self;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    // Modify input text
    self.inputText.frame = CGRectMake(10, 7, self.bounds.size.width - 20, 24);
    
    [self addSubview:self.textInput];
    self.textInput.frame = CGRectMake(10, 7, self.bounds.size.width - 20, self.bounds.size.height - 14);
}

- (void)reloadFieldData
{
    self.textInput.text = [self.form.formData objectForKey:self.name];
    [self textViewDidChange:self.textInput];
}

#pragma mark - text view methods
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text == nil
        || [textView.text isEqualToString:@""]
    ) {
        self.inputText.hidden = NO;
    } else {
        self.inputText.hidden = YES;
    }
    [self updateFormData:textView.text];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Move to next input text
    [self moveToNextInputText];
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
