//
//  KlarnaModel.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/9/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "KlarnaModel.h"



@implementation KlarnaModel

-(void) getKlarnaUSURLWithOrder:(NSString *)orderID{
    currentNotificationName = DidGetKlarnaURL;
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetKlarnaUSURL];
    [[self getAPI] requestWithMethod:POST URL:url params:@{@"order_id":orderID} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

-(void) getKlarnaURLWithOrder:(NSString *)orderID{
    currentNotificationName = DidGetKlarnaURL;
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetKlarnaURL];
    [[self getAPI] requestWithMethod:POST URL:url params:@{@"order_id":orderID} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

-(void) didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    if([responseObject isKindOfClass:[SimiMutableDictionary class]]){
        NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
        if([currentNotificationName isEqualToString:DidGetKlarnaURL]){
            [self setData: responseObjectData];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }
    if (responseObject == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }
}

@end
