//
//  CheckKeyModel.m
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "StoreModel.h"
#import "StoreAPI.h"

@implementation StoreModel


- (void)setStoreDataWithParams:(NSDictionary*) params{
    currentNotificationName = @"DidSetStoreData";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    [(StoreAPI *) [self getAPI] setStoreDataWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
