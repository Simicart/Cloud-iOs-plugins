//
//  SimiIpayModel.m
//  SimiCartPluginFW
//
//  Created by Lionel on 3/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiIpayModel.h"
#import "SimiIpayAPI.h"

@implementation SimiIpayModel
- (void)getConfigWithParams:(NSMutableDictionary *)params{
    modelActionType = ModelActionTypeInsert;
    currentNotificationName = @"DidGetConfig";
    [self preDoRequest];
    [(SimiIpayAPI *)[self getAPI] getConfigWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)updateIpayOrderWithParams:(NSMutableDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidUpdateIpayPayment";
    [self preDoRequest];
    [(SimiIpayAPI *)[self getAPI] updateIpayOrderWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

-(void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder {
    if ([currentNotificationName isEqualToString:@"DidGetConfig"]) {
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            if (responder.simiObjectName) {
                currentNotificationName = responder.simiObjectName;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:responseObjectData];
                }
                    break;
                default:{
                    [self setData:responseObjectData];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    } else if ([currentNotificationName isEqualToString:@"DidUpdateIpayPayment"]) {
        NSLog(@"responseObject : %@", responseObject);
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"order"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"order"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }
}
@end
