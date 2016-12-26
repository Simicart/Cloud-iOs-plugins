//
//  LoginTryDemoModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "LoginTryDemoModel.h"
#import "LoginTryDemoAPI.h"

@implementation LoginTryDemoModel

- (void)loginTryDemo{
    currentNotificationName = @"DidLoginTryDemo";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"getDemoData" forKey:@"method"];

    [(LoginTryDemoAPI *) [self getAPI] loginTryDemoWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
