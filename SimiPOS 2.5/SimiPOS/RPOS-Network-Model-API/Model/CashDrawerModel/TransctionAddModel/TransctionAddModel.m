//
//  CategoryModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "TransctionAddModel.h"
#import "TransctionAddAPI.h"

@implementation TransctionAddModel

- (void)getTransactionAdd:(NSString *)amount note:(NSString*)note type:(NSString*)type{
    currentNotificationName = @"DidGetTransactionAdd";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"transaction.add" forKey:@"method"];
    [params setValue:amount forKey:@"amount"];
    [params setValue:note forKey:@"note"];
    [params setValue:type forKey:@"type"];
    
    [(TransctionAddAPI *) [self getAPI] getTransctionAddWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
