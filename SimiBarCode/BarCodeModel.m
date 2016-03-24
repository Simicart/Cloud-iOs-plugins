//
//  BarCodeModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeModel.h"

@implementation BarCodeModel

-(void) getProductIdWithBarCode:(NSString* )barCode{
    currentNotificationName = DidGetProductIdWithBarCode;
    modelActionType = ModelActionTypeGet;
    NSString* url = [NSString stringWithFormat:@"%@products",kBaseURL];
    [[SimiAPI new] requestWithMethod:GET URL:url params:@{@"filter[or][barcode]":barCode,@"filter[or][qrcode]":barCode} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    if (responder.simiObjectName) {
        currentNotificationName = responder.simiObjectName;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
    
    if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
        switch (modelActionType) {
            case ModelActionTypeInsert:{
                [self addData:(NSDictionary *)responseObject];
            }
                break;
            case ModelActionTypeGet:{
                [self setData:(NSDictionary *)responseObject];
            }
                break;
            default:{
                [self setData:(NSDictionary *)responseObject];
            }
                break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    if (![currentNotificationName isEqualToString:@"DidFinishRequest"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishRequest" object:self userInfo:@{@"responder":responder}];
    }
}

@end
