//
//  MSFormPassword.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormPassword.h"

@implementation MSFormPassword

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        [self.inputText setSecureTextEntry:YES];
    }
    return self;
}

@end
