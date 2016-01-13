//
//  SimiBraintreeModel.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/30/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiBraintreeModel.h"

NSString* const kBraintreeUpdatePayment = @"braintree/update-braintree-payment";
NSString* const kBraintreeGetToken = @"braintree/token";
NSString* const kBraintreeGetSetting = @"braintree/setting";
NSString* const BRAINTREESENDNONCETOSERVER = @"BRAINTREE-SENDNONCETOSERVER";
NSString* const BRAINTREEGETSETTING = @"BRAINTREE-GETSETTING";
NSString* const BRAINTREEGETTOKEN = @"BRAINTREE-GETTOKEN";

@implementation SimiBraintreeModel
-(void) sendNonceToServer:(NSString* )nonce andOrderID:(NSString *)orderID{
    currentNotificationName = BRAINTREESENDNONCETOSERVER;
    SimiAPI *braintreeAPI = [[SimiAPI alloc] init];
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kBraintreeUpdatePayment];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{@"nonce":nonce,@"order_id":orderID}];
    [braintreeAPI requestWithMethod:POST URL:url params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}
-(void) getSetting{
    currentNotificationName = BRAINTREEGETSETTING;
    SimiAPI *braintreeAPI = [SimiAPI new];
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL,kBraintreeGetSetting];
    [braintreeAPI requestWithMethod:GET URL:url params:nil target:self selector:@selector(didFinishRequest:responder:) header:nil];
}


-(void) getToken{
    currentNotificationName = BRAINTREEGETTOKEN;
    SimiAPI *braintreeAPI = [SimiAPI new];
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kBraintreeGetToken];
    [braintreeAPI requestWithMethod:GET URL:url params:nil target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

-(void) didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    if ([currentNotificationName isEqualToString:BRAINTREEGETSETTING] || [currentNotificationName isEqualToString:BRAINTREESENDNONCETOSERVER] || [currentNotificationName isEqualToString:BRAINTREEGETTOKEN]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    if([currentNotificationName isEqualToString:BRAINTREEGETSETTING] || [currentNotificationName isEqualToString:BRAINTREEGETTOKEN])
                        [self addData:responseObjectData];
                    else if([currentNotificationName isEqualToString:BRAINTREESENDNONCETOSERVER])
                            [self addData:[responseObjectData valueForKey:@"invoice"]];
                }
                    break;
                default:{
                    if([currentNotificationName isEqualToString:BRAINTREEGETSETTING] || [currentNotificationName isEqualToString:BRAINTREEGETTOKEN])
                        [self setData:responseObjectData];
                    else if([currentNotificationName isEqualToString:BRAINTREESENDNONCETOSERVER])
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
