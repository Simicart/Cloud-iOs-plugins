//
//  SimiCustomerModel+Facebook.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/20/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiCustomerModel+Facebook.h"

@implementation SimiCustomerModel (Facebook)

- (void)loginWithFacebookEmail:(NSString *)email name:(NSString *)name{
    currentNotificationName = DidLogin;
    [(SimiCustomerAPI *)[self getAPI] loginFacebookWithParams:@{@"email":email, @"first_name":name, @"last_name":@""} target:self selector:@selector(didFinishRequest:responder:)];
}

-(void) didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
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
            case ModelActionTypeEdit:{
                [self editData:(NSDictionary *)responseObject];
            }
                break;
            case ModelActionTypeDelete:{
                [self deleteData];
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
