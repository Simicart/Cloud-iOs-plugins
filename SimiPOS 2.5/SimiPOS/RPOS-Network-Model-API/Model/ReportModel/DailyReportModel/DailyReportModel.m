//
//  DailyReportModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "DailyReportModel.h"
#import "DailyReportAPI.h"

@implementation DailyReportModel

- (void)getDailyReport{
    currentNotificationName = @"DidGetDailyReport";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"report.dailyReport" forKey:@"method"];
    
    [(DailyReportAPI *) [self getAPI] getDailyReportWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
