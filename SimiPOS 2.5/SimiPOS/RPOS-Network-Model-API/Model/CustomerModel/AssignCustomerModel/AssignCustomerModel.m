//
//  CheckKeyModel.m
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "AssignCustomerModel.h"
#import "AssignCustomerAPI.h"

@implementation AssignCustomerModel


- (void)assignCustomerWithCustomerID:(NSDictionary*) customerId{
    currentNotificationName = @"DidAssignCustomer";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    NSString *method = @"checkout_customer.set";
    
    if (customerId != nil) {
        [paramsDict setValue:customerId forKey:@"id"];
        [paramsDict setValue:@"customer" forKey:@"mode"];
    }else{
        [paramsDict setValue:@"guest" forKey:@"mode"];
    }
    
    paramsArr = [[NSMutableArray alloc]initWithObjects:paramsDict, nil];
    
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
    
    [(AssignCustomerAPI *) [self getAPI] assignCustomerWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
