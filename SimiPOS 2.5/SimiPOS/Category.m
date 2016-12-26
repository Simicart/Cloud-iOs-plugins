//
//  Category.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Category.h"

@implementation Category

-(NSString *)getName
{
    return (NSString *)[self objectForKey:@"name"];
}

-(NSUInteger)getLevel
{
    return [[self objectForKey:@"level"] integerValue];
}

@end
