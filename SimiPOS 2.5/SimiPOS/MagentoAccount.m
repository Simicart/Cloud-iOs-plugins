//
//  MagentoAccount.m
//  SimiPOS
//
//  Created by Marcus on 2/3/16.
//  Copyright (c) 2016  Nguyen Duc Chien. All rights reserved.
//

#import "MagentoAccount.h"

@implementation MagentoAccount

#pragma mark - implement abstract
- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"info" forKey:@"method"];
    return params;
}

- (NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    NSMutableDictionary *params = [super prepareSave:model withAction:action];
    [params setValue:@"update" forKey:@"method"];
    [params setValue:[NSNumber numberWithBool:YES] forKey:@"app"];
    [params setValue:@[model] forKey:@"params"];
    return params;
}

#pragma mark - Magestore Authenticate
- (void)authorize:(Account *)account
{
    Configuration *config = [Configuration globalConfig];
    NSURL *url = [NSURL URLWithString:[config objectForKey:API_URL_NAME]];
    
    MSHTTPRequest *request = [MSHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:60];
    __weak MSHTTPRequest *request_temp = request;
    
    // Authenticate Params
    [request addPostValue:[account objectForKey:@"email"] forKey:@"username"];
    [request addPostValue:[account objectForKey:@"password"] forKey:@"password"];
    [request addPostValue:@"login" forKey:@"method"];
    
    // Attach Device ID and Device Name to Request
    [request addPostValue:[[UIDevice currentDevice] name] forKey:@"device_name"];
    [request addPostValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"device_id"];
    [request addPostValue:[[UIDevice currentDevice] model] forKey:@"device_model"];
    
    if ([Configuration isDev]) {
        [request addPostValue:@"1" forKey:@"dev"];
    }
    
    [request setCompletionBlock:^{
        NSData *responseData = [request_temp responseData];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        
        
        NSMutableDictionary * mutableResult =[[NSMutableDictionary alloc] initWithDictionary:result];
        
        if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary * data =[result objectForKey:@"data"];
            
            NSString * session =[NSString stringWithFormat:@"%@",[data objectForKey:@"session"]];
            
            [mutableResult setObject:session forKey:@"session"];
            [account addData:mutableResult];
            
            [[Configuration globalConfig] setObject:session forKey:@"session"];
            
        }
    }];
    [request setFailedBlock:^{
        // Request to server fail
    }];
    [request startSynchronous];
}


@end
