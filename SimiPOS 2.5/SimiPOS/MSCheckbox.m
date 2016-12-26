//
//  MSCheckbox.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/9/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSCheckbox.h"

@implementation MSCheckbox

- (id)init
{
    if (self = [super init]) {
        self.strokeColor = [UIColor grayColor];
    }
    return self;
}

#pragma mark - Implement uiswitch
- (void)setOn:(BOOL)on
{
    if (on) {
        [self setCheckState:M13CheckboxStateChecked];
    } else {
        [self setCheckState:M13CheckboxStateUnchecked];
    }
}

- (BOOL)isOn
{
    return [self checkState] == M13CheckboxStateChecked;
}

@end
