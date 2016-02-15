//
//  SimiStoreLocatorModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorModelCollection.h"

@implementation SimiStoreLocatorModelCollection
- (void)getStoreListWithLatitude:(NSString*)lat longitude:(NSString*)lng offset:(NSString*)offset limit:(NSString*)limit
{
    currentNotificationName = @"StoreLocator_DidGetStoreList";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    [(SimiStoreLocatorAPI *)[self getAPI] getStoreListWithParams:nil target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getStoreListWithLatitude:(NSString *)lat longitude:(NSString *)lng offset:(NSString *)offset limit:(NSString *)limit country:(NSString*)country city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString *)tag
{
    currentNotificationName = @"StoreLocator_DidGetStoreList";
    modelActionType = ModelActionTypeInsert;
    [self preDoRequest];
    [(SimiStoreLocatorAPI *)[self getAPI] getStoreListWithParams:@{@"lat":lat,@"lng":lng,@"offset":offset,@"limit":limit,@"country":country,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag} target:self selector:@selector(didFinishRequest:responder:)];
}

-(void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder {
    if ([currentNotificationName isEqualToString:@"StoreLocator_DidGetStoreList"]) {
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            if (responder.simiObjectName) {
                currentNotificationName = responder.simiObjectName;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
//                    [self addData:responseObjectData];
                    NSLog(@"location data : %@", responseObjectData);
                    [self addObjectsFromArray:[responseObjectData objectForKey:@"store_locations"]];
                }
                    break;
                default:{
                    [self removeAllObjects];
                    [self addObjectsFromArray:[responseObjectData objectForKey:@"store_locations"]];
//                    [self setData:responseObjectData];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    } else if ([currentNotificationName isEqualToString:@"DidUpdatePayUIndianPaymentConfig"]) {
        
    }
}

@end
