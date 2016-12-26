//
//  UITextInputAssistantItem+RemoveBars.m
//  SimiPOS
//
//  Created by mac on 2/18/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import "UITextInputAssistantItem+RemoveBars.h"

@implementation UITextInputAssistantItem (RemoveBars)

- (NSArray<UIBarButtonItemGroup *> *)leadingBarButtonGroups
{
    return @[];
}

- (NSArray<UIBarButtonItemGroup *> *)trailingBarButtonGroups
{
    return @[];
}

@end
