//
//  CategoryModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "TransactionListModel.h"
#import "TransactionListAPI.h"

@implementation TransactionListModel

- (void)getTransactionList{
    currentNotificationName = @"DidGetTransactionList";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"transaction.list" forKey:@"method"];
    
    [(TransactionListAPI *) [self getAPI] getTransactionListWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
