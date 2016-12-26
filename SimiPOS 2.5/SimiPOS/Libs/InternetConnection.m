//
//  InternetConnection.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/19/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "InternetConnection.h"

@implementation InternetConnection

+(BOOL)canAccess
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    if ([internetReach isReachable]) {
        return YES;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", nil) message:NSLocalizedString(@"The Internet connection appears to be offline.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert show];
    return NO;
}

@end
