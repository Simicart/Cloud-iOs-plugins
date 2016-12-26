//
//  CheckKeyModel.m
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CheckKeyModel.h"
#import "CheckKeyAPI.h"

@implementation CheckKeyModel

- (void)checkKeyFromMagestore:(NSString*)key{
    currentNotificationName = @"DidCheckKeyFromMagestore";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:key forKey:@"api_key"];
    [params setValue:@"getStoreUrl" forKey:@"method"];

    [(CheckKeyAPI *) [self getAPI] checkKeyFromMagestoreWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
