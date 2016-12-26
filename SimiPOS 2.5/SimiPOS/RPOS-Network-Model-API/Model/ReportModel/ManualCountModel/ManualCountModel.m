//
//  ManualCountModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ManualCountModel.h"
#import "ManualCountAPI.h"

@implementation ManualCountModel

- (void)getManualCount{
    currentNotificationName = @"DidGetManualCount";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"report.getDenomination" forKey:@"method"];
    
    [(ManualCountAPI *) [self getAPI] getManualCountWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
