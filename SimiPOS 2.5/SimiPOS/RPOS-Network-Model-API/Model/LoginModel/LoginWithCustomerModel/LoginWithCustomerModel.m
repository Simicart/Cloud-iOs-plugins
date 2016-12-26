//
//  LoginWithCustomerModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "LoginWithCustomerModel.h"
#import "LoginWithCustomerAPI.h"

@implementation LoginWithCustomerModel

- (void)loginWithCustomer:(NSString*)username password:(NSString*) password{
    currentNotificationName = @"DidLoginWithCustomer";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"login" forKey:@"method"];
    [params setValue:username forKey:@"username"];
    [params setValue:password forKey:@"password"];
    
    [(LoginWithCustomerAPI *) [self getAPI] loginCustomerWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];

}

@end
