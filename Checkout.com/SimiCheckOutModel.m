//
//  SimiCheckOutModel.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiCheckOutModel.h"
#import "SimiCheckOutAPI.h"

@implementation SimiCheckOutModel
-(void)getPublishKey:(NSDictionary *)params {
    currentNotificationName = @"DidGetCheckOutPublishKeyConfig";
    modelActionType = ModelActionTypeGet;
    [(SimiCheckOutAPI *)[self getAPI] getPublishKeyWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}
-(void)createCheckOutPaymentWithParam:(NSDictionary *)params {
    currentNotificationName = @"DidCreateCheckOutPaymentConfig";
    modelActionType = ModelActionTypeGet;
    [(SimiCheckOutAPI *)[self getAPI] createCheckOutPaymentWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

-(void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder {
    if ([currentNotificationName isEqualToString:@"DidGetCheckOutPublishKeyConfig"]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
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
    } else if ([currentNotificationName isEqualToString:@"DidCreateCheckOutPaymentConfig"]) {
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"invoice"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"invoice"]];
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
