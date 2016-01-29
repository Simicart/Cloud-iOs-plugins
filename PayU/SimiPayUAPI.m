//
//  SimiPayUAPI.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUAPI.h"
#import "SimiGlobalVar+PayU.h"

@implementation SimiPayUAPI
-(void)getDirectLinkWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector {
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSCGetPayUDirectLink];
    [self requestWithMethod:@"POST" URL:url params:params target:target selector:selector header:nil];
}
@end
