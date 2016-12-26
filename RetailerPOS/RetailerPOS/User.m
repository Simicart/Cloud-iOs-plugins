//
//  User.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "User.h"
#import "MagentoUser.h"

@implementation User

- (id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"User";
    }
    return self;
}

#pragma mark - delete user
- (void)deleteUser
{
    MagentoUser *resource = (MagentoUser *)[self getResource];
    [resource deleteUser:self finished:@selector(deleteUserSuccess)];
}

- (void)deleteUserSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDeleteAfter" object:self];
}

@end
