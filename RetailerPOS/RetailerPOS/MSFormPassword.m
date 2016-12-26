//
//  MSFormPassword.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
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
