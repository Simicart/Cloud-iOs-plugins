//
//  Category.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "RPCategory.h"

@implementation RPCategory

-(NSString *)getName
{
    NSString *category_name = [self objectForKey:@"name"];
    if([category_name isKindOfClass:[NSNull class]]){
        category_name = @"";
    }
    return category_name;
}

-(NSUInteger)getLevel
{
    return [[self objectForKey:@"level"] integerValue];
}

@end
