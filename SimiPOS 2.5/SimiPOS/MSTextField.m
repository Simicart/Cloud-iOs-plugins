//
//  MSTextField.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSTextField.h"

@implementation MSTextField
@synthesize textPadding;

#pragma mark - add text padding
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(textPadding.left, textPadding.top, bounds.size.width - textPadding.left - textPadding.right, bounds.size.height - textPadding.top - textPadding.bottom);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    if ((self.clearButtonMode == UITextFieldViewModeAlways || self.clearButtonMode == UITextFieldViewModeWhileEditing) && self.text != nil && ![self.text isEqualToString:@""]) {
        CGRect rect = [self textRectForBounds:bounds];
        rect.size.width -= 27 - textPadding.right;
        return rect;
    }
    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 27, textPadding.top, 21, 21);
}

@end
