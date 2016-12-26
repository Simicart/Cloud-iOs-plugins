//
//  GetCustomerAddressModel.m
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "GetCustomerAddressModel.h"
#import "GetCustomerAddressAPI.h"

@implementation GetCustomerAddressModel


- (void)getCustomerAddressWithID:(NSString*) customerId{
    currentNotificationName = @"DidGetCustomerAddress";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];

    NSString *method = @"customer_address.address";
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:[NSString stringWithFormat:@"[\"%@\"]",customerId] forKey:@"params"];
    DLog(@"%@",params);
    
    [(GetCustomerAddressAPI *) [self getAPI] getCustomerWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
