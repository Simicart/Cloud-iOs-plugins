//
//  SaveCustomerInfoModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/28/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SaveCustomerInfoModel.h"
#import "SaveCustomerInfoAPI.h"

@implementation SaveCustomerInfoModel

- (void)saveCustomerInfoWithData:(NSDictionary *)data{
    
    currentNotificationName = @"DidSaveCustomerInfo";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSString *method = @"";

    paramsArr = [[NSMutableArray alloc]init];
    if ([data valueForKey:@"id"]) {
        method = @"customer.update";
        [paramsArr addObject:[data valueForKey:@"id"]];
    }else{
        method = @"customer.create";
    }
    [paramsArr addObject:data];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsArr
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *paramsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];

    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:paramsStr forKey:@"params"];
    DLog(@"%@",params);
    
    [(SaveCustomerInfoAPI *) [self getAPI] saveCustomerInfoWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
