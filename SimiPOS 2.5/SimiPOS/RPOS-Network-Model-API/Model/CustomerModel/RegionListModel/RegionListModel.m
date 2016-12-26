//
//  RegionListModel.m
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RegionListModel.h"
#import "RegionListAPI.h"

@implementation RegionListModel


- (void)getRegionListWithCountryCode:(NSString *)countryCode{
    currentNotificationName = @"DidGetRegionList";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];

    NSString *method = @"locale.region";
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:[NSString stringWithFormat:@"[\"%@\"]",countryCode] forKey:@"params"];
    DLog(@"%@",params);
    
    [(RegionListAPI *) [self getAPI] getRegionListWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
