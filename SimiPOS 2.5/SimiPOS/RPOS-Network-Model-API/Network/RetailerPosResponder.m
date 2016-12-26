//
//  SimiResponder.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosResponder.h"

@implementation RetailerPosResponder

@synthesize status, message, error, other;
//  Liam ADD 150316
@synthesize layerNavigation;
//  End 150316

- (id)init
{
    self = [super init];
    if (self) {
        status = @"";
        message = nil;
        error = nil;
    }
    return self;
}

- (NSString *)responseMessage{
    NSString *mess;
    if (error == nil) {
        if (message.count >= 1) {
            mess = [NSString stringWithFormat:@"%@", [message objectAtIndex:0]];
            int i = 1;
            while (i < message.count) {
                NSString *me = [message objectAtIndex:i];
                mess = [NSString stringWithFormat:@"%@\n%@", mess, me];
                i++;
            }
        }
    }else{
        mess = error.localizedDescription;
    }
    return mess;
}

@end
