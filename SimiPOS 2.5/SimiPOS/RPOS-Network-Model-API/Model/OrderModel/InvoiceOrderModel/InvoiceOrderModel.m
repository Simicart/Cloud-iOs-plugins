//
//  InvoiceOrderModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "InvoiceOrderModel.h"
#import "InvoiceOrderAPI.h"

@implementation InvoiceOrderModel

- (void)invoiceOrder:(NSString*)orderID{
    currentNotificationName = @"DidInvoiceOrder";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramID = [NSString stringWithFormat:@"%@%@%@", @"\"", orderID, @"\""];
    
    
    NSString *paramsOrder = [NSString stringWithFormat:@"[%@]", paramID];
    
    DLog(@"InvoiceOrderModel_ParamOrder:%@", paramsOrder);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order_invoice.create" forKey:@"method"];
    [params setValue:paramsOrder forKey:@"params"];
    
    [(InvoiceOrderAPI *) [self getAPI] invoiceOrderWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
