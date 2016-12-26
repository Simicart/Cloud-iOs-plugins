//
//  NSArray+MutableDeepCopy.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/18/13.
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
