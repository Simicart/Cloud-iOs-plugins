//
//  EditItemOptions.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/7/2016.
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
