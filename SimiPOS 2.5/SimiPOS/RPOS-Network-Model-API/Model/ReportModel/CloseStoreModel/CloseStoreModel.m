//
//  CloseStoreModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CloseStoreModel.h"
#import "CloseStoreAPI.h"

@implementation CloseStoreModel

- (void)closeStore:(NSString*)cashCount openingAmount:(NSString*)openingAmount{
    currentNotificationName = @"DidCloseStore";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"report.closeStore" forKey:@"method"];
    [params setValue:cashCount forKey:@"cash_count"];
    [params setValue:openingAmount forKey:@"openning_amount"];
    
    [(CloseStoreAPI *) [self getAPI] closeStoreWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
