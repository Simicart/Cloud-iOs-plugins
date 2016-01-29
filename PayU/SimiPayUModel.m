//
//  SimiPayUModel.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUModel.h"
#import "SimiPayUAPI.h"

@implementation SimiPayUModel
-(void)getDirectLink:(NSDictionary *)params {
    currentNotificationName = @"DidGetPayUDirectLinkConfig";
    modelActionType = ModelActionTypeGet;
    [(SimiPayUAPI *)[self getAPI] getDirectLinkWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

-(void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder {
    if ([currentNotificationName isEqualToString:@"DidGetPayUDirectLinkConfig"]) {
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
    }
}

@end
