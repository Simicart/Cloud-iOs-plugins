//
//  SimiOrderModel+PayPal.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/28/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiOrderModel+PayPal.h"
#import "SimiOrderAPI+PayPal.h"

@implementation SimiOrderModel (PayPal)

- (void)updateOrderWithPaymentStatus:(PaymentStatus)paymentStatus proof:(NSDictionary *)proof{
    currentNotificationName = @"DidUpdatePaymentStatus";
    if (proof == nil) {
        proof = @{};
    }
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setValue:[self valueForKey:@"_id"] forKey:@"order_id"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)paymentStatus] forKey:@"payment_status"];
    [params setValue:proof forKey:@"proof"];
    
    [(SimiOrderAPI *)[self getAPI] updateOrderWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

//-(void) didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
//    if([currentNotificationName isEqualToString:DidUpdatePaymentStatus]){
//        if (responder.simiObjectName) {
//            currentNotificationName = responder.simiObjectName;
//        }
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
//        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
//            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
//            
//            switch (modelActionType) {
//                case ModelActionTypeInsert:{
//                    [self addData:[responseObjectData valueForKey:@"order"]];
//                }
//                    break;
//                default:{
//                    [self setData:[responseObjectData valueForKey:@"order"]];
//                }
//                    break;
//            }
//            //            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
//        }else if (responseObject == nil){
//            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
//        }
//    }
//    else{
//        [super didFinishRequest:responseObject responder:responder];
//    }
//}
@end
