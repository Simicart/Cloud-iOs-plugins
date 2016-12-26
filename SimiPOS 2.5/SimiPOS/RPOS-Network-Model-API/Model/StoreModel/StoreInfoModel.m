//
//  StoreInfoModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "StoreInfoModel.h"
#import "StoreInfoAPI.h"

@implementation StoreInfoModel

- (void)getStoreInfo{
    
    currentNotificationName = @"DidGetStoreInfo";
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
   
    NSString *method = @"storeInfo";
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    DLog(@"%@",params);
    

    [(StoreInfoAPI *) [self getAPI] getStoreInfoWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}





@end
