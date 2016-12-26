//
//  UIView+InputNotification.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/30/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "UIView+InputNotification.h"

@implementation UIView (InputNotification)

+ (UIView *)firstResponder:(UIView *)responder
{
    static UIView *firstResponder;
    if (responder != nil) {
        firstResponder = responder;
    }
    return firstResponder;
}

#pragma mark - Rewrite Core Methods
- (BOOL)resignFirstResponder
{
    if ([self isKindOfClass:[UITextField class]]
        || [self isKindOfClass:[UITextView class]]
        || [[[self class] description] isEqualToString:@"UISearchBarTextField"]
    ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UIViewResignFirstResponder" object:self];
    }
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [UIView firstResponder:self];
    return [super becomeFirstResponder];
}

#pragma mark - Clone a view
- (id)clone
{
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject:self];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}

@end
