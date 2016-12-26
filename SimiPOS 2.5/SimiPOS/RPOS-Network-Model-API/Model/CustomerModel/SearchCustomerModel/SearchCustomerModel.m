//
//  SearchCustomerModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SearchCustomerModel.h"
#import "SearchCustomerAPI.h"

@implementation SearchCustomerModel

- (void)searchCustomerWidthKeySearch:(NSString *)keySearch index:(NSString*)index length:(NSString*)length{
    currentNotificationName = @"DidSearchCustomer";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSString *method = @"customer.search";
    
    paramsArr = [[NSMutableArray alloc]init];
    [paramsArr addObject:keySearch];
    [paramsArr addObject:index];
    [paramsArr addObject:length];
    
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
    
    [(SearchCustomerAPI *) [self getAPI] searchCustomerWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
