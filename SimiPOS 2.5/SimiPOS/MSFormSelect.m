//
//  MSFormSelect.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormSelect.h"
#import "MSForm.h"
#import "MSFormSelectOptions.h"

@implementation MSFormSelect
@synthesize inputText;
@synthesize dataSource, optionsPopover;

#pragma mark - Abstract methods
- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        // Init Input Text View
        self.inputText = [[UITextField alloc] init];
        self.inputText.delegate = self;
        self.inputText.clearsOnBeginEditing = NO;
        
        if (self.required) {
            self.inputText.placeholder = [NSString stringWithFormat:@"%@ (%@)", self.title, NSLocalizedString(@"Required", nil)];
        } else {
            self.inputText.placeholder = self.title;
        }
        self.inputText.font = [UIFont systemFontOfSize:18];
        self.inputText.clearButtonMode = UITextFieldViewModeAlways;
        
        // Data Source (KEY => VALUE)
        self.dataSource = [data objectForKey:@"source"];
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
    id currentValue = [self.form.formData objectForKey:self.name];
    if (currentValue != nil) {
        if ([self.dataSource objectForKey:currentValue] == nil) {
            if ([currentValue isKindOfClass:[NSString class]]) {
                self.inputText.text = currentValue;
            } else {
                self.inputText.text = [currentValue stringValue];
            }
        } else {
            self.inputText.text = [self.dataSource objectForKey:currentValue];
        }
    } else {
        self.inputText.text = nil;
    }
}

#pragma mark - Text field and select data
- (void)updateSelectInput:(NSArray *)selected
{
    for (id option in selected) {
        [self updateFormData:option];
    }
    [self reloadFieldData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.inputText.text = nil;
    [self updateFormData:nil];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Show select options
    if (self.optionsPopover == nil) {
        MSFormSelectOptions *popupOptions = [[MSFormSelectOptions alloc] init];
        popupOptions.selectInput = self;
        
        self.optionsPopover = [[UIPopoverController alloc] initWithContentViewController:popupOptions];
        self.optionsPopover.delegate = popupOptions;
    }
    MSFormSelectOptions *popupOptions = (MSFormSelectOptions *)self.optionsPopover.delegate;
    
    // show popover
    self.optionsPopover.popoverContentSize = [popupOptions reloadContentSize];
    [self.optionsPopover presentPopoverFromRect:self.inputText.frame inView:self permittedArrowDirections:(UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight) animated:YES];
    
    // reload selected
    if ([self.form.formData objectForKey:self.name]) {
        popupOptions.selectedOptions = @[[self.form.formData objectForKey:self.name]];
    } else {
        popupOptions.selectedOptions = [NSArray new];
    }
    [popupOptions reloadData];
    return NO;
}

@end
