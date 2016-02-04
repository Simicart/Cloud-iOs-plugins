//
//  CCAvenueModel.m
//  SimiCartPluginFW
//
//  Created by Axe on 1/20/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "CCAvenueModel.h"

const NSString *kSimiCCAvenueGetRSA = @"ccavenue/rsa";
const NSString *kSimiCCAvenueUpdatePayment = @"ccavenue/update-ccavenue-payment";

@implementation CCAvenueModel

-(void) getRSAForOrder:(NSString *)orderID{
    NSString* url = [NSString stringWithFormat:@"%@%@",kBaseURL, kSimiCCAvenueGetRSA];
    currentNotificationName = DidGetRSACCAvenue;
    [[SimiAPI new] requestWithMethod:POST URL:url params:@{@"order_id":orderID} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

-(void) updatePaymentWithOrder:(NSString *)orderID status:(NSString *)status{
    NSString* url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiCCAvenueUpdatePayment];
    currentNotificationName = DidUpdateCCAvenuePayment;
    [[SimiAPI new] requestWithMethod:POST URL:url params:@{@"order_id":orderID,@"status":status} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

-(void) didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
        if([responseObject isKindOfClass:[SimiMutableDictionary class]]){
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            if([currentNotificationName isEqualToString:DidGetRSACCAvenue]){                        [self setData:responseObjectData];
                
            }else if([currentNotificationName isEqualToString:DidUpdateCCAvenuePayment]){
                if([responseObjectData objectForKey:@"invoice"]){
                    [self setData:[responseObjectData objectForKey:@"invoice"]];
                }else if([responseObjectData objectForKey:@"order"]){
                    [self setData:[responseObjectData objectForKey:@"order"]];
                }else if([[responseObjectData objectForKey:@"errors"] objectAtIndex:0]){
                    [self setData:[[responseObjectData objectForKey:@"errors"] objectAtIndex:0]];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
        if (responseObject == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
}

@end
