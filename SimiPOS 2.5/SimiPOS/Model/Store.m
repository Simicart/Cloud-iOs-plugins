//
//  Store.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/25/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Store.h"
#import "Configuration.h"

@interface Store()

@end

@implementation Store

- (id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Store";
        self.isLoadedInfo = NO;
    }
    return self;
}

+ (Store *)currentStore
{
    return (Store *)[Configuration getSingleton:@"Store"];
}

- (BOOL)isLoaded
{
    return self.isLoadedInfo;
}

- (void)clear
{
    self.isLoadedInfo = NO;
}

- (void)loadSuccess
{
    self.isLoadedInfo = YES;
    [super loadSuccess];
}

@end
