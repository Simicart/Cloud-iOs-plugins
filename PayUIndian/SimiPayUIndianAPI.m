//
//  SimiPayUIndianAPI.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 2/2/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUIndianAPI.h"

@implementation SimiPayUIndianAPI
-(void)getPaymentHashWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector {
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSCPayUIndianGetPaymentHash];
    [self requestWithMethod:@"POST" URL:url params:params target:target selector:selector header:nil];
}
-(void)updatePayUIndianPaymentWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector {
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSCPayUIndianUpdatePayment];
    [self requestWithMethod:@"POST" URL:url params:params target:target selector:selector header:nil];
}
@end
