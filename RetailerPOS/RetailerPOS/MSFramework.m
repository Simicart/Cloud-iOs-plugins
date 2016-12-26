//
//  MSFramework.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/4/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFramework.h"

@implementation MSFramework

+ (BOOL)isIOS8
{
    return ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending);
}

@end
