//
//  SimiPayUIndianModel.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 2/2/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUIndianModel.h"
#import "SimiPayUIndianAPI.h"

@implementation SimiPayUIndianModel

-(void)getPaymentHash:(NSDictionary *)params {
    currentNotificationName = @"DidGetPayUIndianPaymentHashConfig";
    modelActionType = ModelActionTypeGet;
    [(SimiPayUIndianAPI *)[self getAPI] getPaymentHashWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

-(void)updatePayment:(NSDictionary *)params {
    currentNotificationName = @"DidUpdatePayUIndianPaymentConfig";
    modelActionType = ModelActionTypeGet;
    [(SimiPayUIndianAPI *)[self getAPI] updatePayUIndianPaymentWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

-(void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder {
    if ([currentNotificationName isEqualToString:@"DidGetPayUIndianPaymentHashConfig"]) {
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
    } else if ([currentNotificationName isEqualToString:@"DidUpdatePayUIndianPaymentConfig"]) {
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
