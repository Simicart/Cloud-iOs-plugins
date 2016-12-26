//
//  DiscountModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "DiscountModel.h"
#import "DiscountAPI.h"

@implementation DiscountModel

- (void)setDiscountWithData:(NSDictionary *)data{
    
    currentNotificationName = @"DidSetDisCount";
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    NSMutableArray *paramsArr = [NSMutableArray new];
//    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    NSString *method = @"";
    
    
    paramsArr = [[NSMutableArray alloc]init];
    if ([data valueForKey:@"coupon"]) {
        method = @"checkout_discount.coupon";
        [paramsArr addObject:[data valueForKey:@"coupon"]];
    }else{
        method = @"checkout_discount.discount";
        [paramsArr addObject:[data valueForKey:@"amount"]];
        [paramsArr addObject:[data valueForKey:@"type"]];
        if ([data valueForKey:@"description"]) {
            [paramsArr addObject:[data valueForKey:@"description"]];
        }
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsArr
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *paramsProductId = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:paramsProductId forKey:@"params"];
    DLog(@"%@",params);
    

    [(DiscountAPI *) [self getAPI] setDiscountWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}





@end
