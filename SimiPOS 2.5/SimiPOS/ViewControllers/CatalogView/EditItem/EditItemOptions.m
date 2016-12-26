//
//  EditItemOptions.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "EditItemOptions.h"
#import "EditItemOptionsMaster.h"
#import "EditItemOptionsDetail.h"

@implementation EditItemOptions

- (id)init
{
    if (self = [super init]) {
        self.masterOptions = [[EditItemOptionsMaster alloc] init];
        self.detailOptions = [[EditItemOptionsDetail alloc] init];
    }
    return self;
}

@end
