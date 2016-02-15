//
//  SimiConfigSearchStoreLocatorModel.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiConfigSearchStoreLocatorModel.h"
#import "SimiGlobalVar+StoreLocator.h"
#import "SimiConfigSearchStoreLocatorAPI.h"
@implementation SimiConfigSearchStoreLocatorModel
- (void)getSearchConfigWithParams:(NSDictionary*)dict
{
    currentNotificationName = @"DidGetSearchConfig";
    modelActionType = ModelActionTypeGet;
    //Gin edit
    [self preDoRequest];
    //end
    [(SimiConfigSearchStoreLocatorAPI *)[self getAPI] getSearchConfigWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}
@end
