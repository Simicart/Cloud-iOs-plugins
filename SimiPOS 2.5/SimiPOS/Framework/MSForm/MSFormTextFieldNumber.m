//
//  MSFormTextFieldNumber.m
//  SimiPOS
//
//  Created by mac on 3/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "MSFormTextFieldNumber.h"
#import "MSFramework.h"
#import "Price.h"


@interface MSFormTextFieldNumber()
@property (strong, nonatomic) MSNumberPad2 *keyboard;
@property (strong, nonatomic) UIPopoverController *optionsPopover;
@end

@implementation MSFormTextFieldNumber
{
    bool checkClear;
}
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
    checkClear =YES;
    self.inputText.text = nil;
    [self updateFormData:nil];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if(checkClear){
        
        checkClear =NO;
        
        return NO;
    }
    
    //Truyen gia tri sang MultiPayment de xu ly
    NSArray * objects =[[NSArray alloc] initWithObjects:textField,self.name,self.title,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormTextFieldNumberBegin" object:objects];
    
    if (keyboard == nil) {
        keyboard = [MSNumberPad2 keyboard];
        [keyboard resetConfig];
        keyboard.doneLabel = @"Done";
        //keyboard.maxInput = 13;
        keyboard.currentValue = 0;
        keyboard.isShowExtButton =YES;
       // keyboard.delegate = self;
        [keyboard showOn:nil atFrame:CGRectMake(10, 0, 476, 330)];
    }
    
    keyboard.delegate = self;
    keyboard.textField = textField;//self.inputText;
    
    self.inputText =textField;
    
    if (optionsPopover == nil) {
        optionsPopover = [[UIPopoverController alloc] initWithContentViewController:keyboard];
        optionsPopover.popoverContentSize = CGSizeMake(476, 330);
        optionsPopover.backgroundColor =[UIColor whiteColor];
    }
    [optionsPopover presentPopoverFromRect:self.inputText.frame inView:self permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionRight) animated:YES];
    return NO;
}

#pragma mark - keyboard
- (BOOL)numberPad:(MSNumberPad2 *)numberPad willChangeValue:(NSInteger)value
{
    NSString *text = inputText.text;
    if (value == 11) { // Delete
        if (text && [text length]) {
            text = [text substringToIndex:([text length] - 1)];
            inputText.text = text;
        }
    }    
    else if (value == 13){
        text = [NSString stringWithFormat:@"%@00", text];
        inputText.text = text;
    }
    
    else if (value == 21){
        
        text = [NSString stringWithFormat:@"%@.", text];
        inputText.text = text;
    }
    else if (value == 22){
        
        text = [NSString stringWithFormat:@"%@,", text];
        inputText.text = text;
    }
    
    
    else {
        text = [NSString stringWithFormat:@"%@%d", text, (int)value];
        inputText.text = text;
    }
    
    [self updateFormData:text];
    
    return NO;
}

- (BOOL)numberPadShouldDone:(MSNumberPad2 *)numberPad
{    
    [optionsPopover dismissPopoverAnimated:NO];
    return YES;
}

- (void)numberPad:(MSNumberPad2 *)numberPad willShowButton:(UIButton *)button
{
    if (button.tag == 23) {
        button.titleLabel.font = [UIFont systemFontOfSize:25];
    }
    
    if (button.tag > 20) {
        button.titleLabel.font = [UIFont systemFontOfSize:24];
        
        if(button.tag == 21){
             [button setTitle:@"." forState:UIControlStateNormal];
            
        }else if(button.tag == 22){
            [button setTitle:@"," forState:UIControlStateNormal];
            
        }
    }
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
