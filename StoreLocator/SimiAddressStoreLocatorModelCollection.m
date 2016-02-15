//
//  SimiAddressStoreLocatorModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiAddressStoreLocatorModelCollection.h"
#import "SimiGlobalVar+StoreLocator.h"
#import "SimiAddressStoreLocatorAPI.h"
@implementation SimiAddressStoreLocatorModelCollection
- (void)getCountryListWithParams:(NSDictionary*)dict
{
    currentNotificationName = @"DidGetCountryCollection";
    modelActionType = ModelActionTypeGet;
    //Gin edit
    [self preDoRequest];
    //end
    [(SimiAddressStoreLocatorAPI *)[self getAPI] getCountryListWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}
@end
