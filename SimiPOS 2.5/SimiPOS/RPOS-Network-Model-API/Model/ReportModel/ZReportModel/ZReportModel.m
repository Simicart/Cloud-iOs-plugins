//
//  ZReportModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ZReportModel.h"
#import "ZReportAPI.h"

@implementation ZReportModel

- (void)getZReport{
    currentNotificationName = @"DidGetZReport";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"report.zreport" forKey:@"method"];
//    [params setValue:@"1" forKey:@"tillid"];
    
    [(ZReportAPI *) [self getAPI] getZReportWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
