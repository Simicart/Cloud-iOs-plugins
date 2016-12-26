//
//  MSFormNumber.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/26/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormNumber.h"

@implementation MSFormNumber

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        [self.inputText setKeyboardType:UIKeyboardTypeDecimalPad];
    }
    return self;
}

@end
