//
//  NSArray+MutableDeepCopy.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/18/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "NSArray+MutableDeepCopy.h"

@implementation NSArray (MutableDeepCopy)

-(NSMutableArray *)mutableDeepCopy
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:self copyItems:YES];
    return newArray;
}

@end
