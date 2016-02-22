//
//  SimiCheckOutAPI.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiCheckOutAPI.h"
#import "SimiGlobalVar+CheckOut.h"

@implementation SimiCheckOutAPI
-(void)getPublishKeyWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector {
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSCGetPublishKey];
    [self requestWithMethod:@"GET" URL:url params:params target:target selector:selector header:nil];
}
-(void)createCheckOutPaymentWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector {
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSCUpdateCheckOutPayment];
    [self requestWithMethod:@"POST" URL:url params:params target:target selector:selector header:nil];
//    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
