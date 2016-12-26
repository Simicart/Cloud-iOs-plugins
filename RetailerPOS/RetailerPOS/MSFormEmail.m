//
//  MSFormEmail.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormEmail.h"

@implementation MSFormEmail

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        [self.inputText setKeyboardType:UIKeyboardTypeEmailAddress];
        self.inputText.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.inputText.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

@end
