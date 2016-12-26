//
//  RetailerPosAPI.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosAPI.h"
#import "RetailerPosResponder.h"
#import "PosMutableArray.h"
#import "PosMutableDictionary.h"
#import "RetailerPosModel.h"
#import "RetailerPosModelCollection.h"
//#import "KeychainItemWrapper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation RetailerPosAPI


- (void)convertData:(id)responseObject{
    if (self.target != nil && self.selector != nil) {
        if ([responseObject isKindOfClass:[NSError class]]) {
            RetailerPosResponder *responder = [[RetailerPosResponder alloc] init];
            responder.retailerPosObjectName = self.retailerPosObjectName;
            responder.error = responseObject;
            responder.status = @"Network Error";
            responder.message = [[NSMutableArray alloc]initWithArray:@[@"Network Error"]];
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.selector withObject:nil withObject:responder];
#pragma clang diagnostic pop
        }else {
            NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if([response valueForKey:@"success"]){
                if([[response valueForKey:@"success"] boolValue]){
                    RetailerPosResponder *responder = [[RetailerPosResponder alloc] init];
                    responder.retailerPosObjectName = self.retailerPosObjectName;
                    responder.status = @"SUCCESS";
                    responder.message = nil;
                    if ([self.target isKindOfClass:NSClassFromString(@"PosMutableDictionary")]) {
                        [self.target performSelector:self.selector withObject:[[PosMutableDictionary alloc]initWithDictionary:response] withObject:responder];
                    }else{
                        [self.target performSelector:self.selector withObject:[[PosMutableDictionary alloc]initWithDictionary:response] withObject:responder];
                    }
                }else{
                    RetailerPosResponder *responder = [[RetailerPosResponder alloc] init];
                    responder.retailerPosObjectName = self.retailerPosObjectName;
                    responder.status = @"ERROR";
                    if([response valueForKey:@"data"]){
                        responder.message = [[NSMutableArray alloc]initWithArray:@[[response valueForKey:@"data"]]];
//                        [responder.message addObject:[response valueForKey:@"data"]];
                    }
                    [self.target performSelector:self.selector withObject:nil withObject:responder];
                }
            }else{
                RetailerPosResponder *responder = [[RetailerPosResponder alloc] init];
                responder.retailerPosObjectName = self.retailerPosObjectName;
                responder.error = responseObject;
                responder.status = @"Network Error";
                responder.message = [[NSMutableArray alloc]initWithArray:@[@"Network Error"]];
                [self.target performSelector:self.selector withObject:nil withObject:responder];
#pragma clang diagnostic pop

            }
        }
    }
}

- (void)requestWithMethod:(NSString*)medthod URL:(NSString *)url params:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header
{
    self.target = (NSObject *)target;
    self.selector = selector;
    
    if ([self.target respondsToSelector:@selector(currentNotificationName)]) {
        self.retailerPosObjectName = [[target currentNotificationName] copy];
    }
    
    if (params == nil) {
        params = @{};
    }
    if (header == nil) {
        header = @{};
    }
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc]initWithDictionary:header];
    
    if ([medthod isEqualToString:POST] || [medthod isEqualToString:PUT]) {
//        [headerParams setValue:@"application/json" forKey:@"Content-Type"];
//        [headerParams setValue:@"YES" forKey:@"Keep-Alive"];
    }
    
    [[RetailerPosNetworkManager sharedInstance] requestWithMethod:medthod urlPath:url parameters:params target:self selector:@selector(convertData:) header:headerParams];
}@end
