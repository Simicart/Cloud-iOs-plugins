//
//  APIManager.m
//  SimiPOS
//
//  Created by Marcus on 12/04/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "APIManager.h"
//#import "PDKeychainBindings.h"

@implementation APIManager

+ (instancetype)shareInstance{
    static APIManager *instance;
    if (!instance) {
        instance = [[APIManager alloc] init];
    }
    return instance;
}

#pragma mark - post default
-(void)post:(NSDictionary *)params callback:(Callback)callback withUrlAPI:(NSString *)apiUrl
{
    NSData *postData ;
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    if(currentSession){
        DLog(@"session:%@",currentSession)
        NSMutableDictionary * paramsExt =[[NSMutableDictionary alloc] initWithDictionary:params];
        [paramsExt setObject:currentSession forKey:@"session"];
        postData =[self encodeDictionary:paramsExt];
        
    }else{
        postData =  [self encodeDictionary:params];
    }
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if(apiUrl && apiUrl.length >0){
        DLog(@" URL Request: %@" , apiUrl);;
        
        [request setURL:[NSURL URLWithString:apiUrl]];
        
    }else{
        [request setURL:[NSURL URLWithString:[config objectForKey:API_URL_NAME]]];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue currentQueue]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         NSString * result =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         DLog(@"result:%@",result);
         
         if ([data length] >0 && error == nil)
         {
             NSDictionary *serverRespone = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
             if (serverRespone) {
                  DLog(@"data respone : %@",serverRespone);
                 if([serverRespone objectForKey:@"success"] && [[serverRespone objectForKey:@"success"] boolValue]){
                     callback(YES, serverRespone);
                 }else{
                     callback(NO, serverRespone);
                 }
                 
             }else{
                 
                 NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 callback(YES, strResponse);
             }
             
         }
         else if ([data length] == 0 && error == nil)
         {
             callback(NO, @"Nothing was downloaded");
         }
         else if (error != nil){
             DLog(@"Error = %@", error);
             callback(NO, error.description);
         }
     }];
}


- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString * encodedValue =nil;
        NSString *part =nil;
        
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            encodedValue =[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
            
        }else {
            encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        if(encodedValue){
            part = [NSString stringWithFormat: @"%@=%@", key, encodedValue];
            [parts addObject:part];
        }
    }];
    
    
//    for (NSString *key in dictionary) {
//        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
//        [parts addObject:part];
//    }
    
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    
    DLog(@"encodedDictionary:%@",encodedDictionary);
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - login
-(void)loginWithUsername:(NSString *)username Password:(NSString *)password Callback:(Callback)callback
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"login", @"method",nil];
    [params setObject:username forKey:@"username"];
    [params setObject:password forKey:@"password"];
    
    [self post:params callback:callback withUrlAPI:nil];
}

#pragma mark - API Reports
-(void)loadReportMidAndEndOfDay:(Callback)callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"report.zreport", @"method",@"1",@"tillid",nil];
    [self post:params callback:callback withUrlAPI:nil];
}

-(void)getListManualCount:(Callback)callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"report.getDenomination", @"method",nil];
    [self post:params callback:callback withUrlAPI:nil];
}


#pragma mark - ZReport Close store
-(void)closeStoreManualCount:(NSString *)manualCount CashAmountKept:(NSString *)cashAmountKept Callback:(Callback)callback
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"report.closeStore", @"method",nil];
    [params setObject:manualCount forKey:@"cash_count"];
    [params setObject:cashAmountKept forKey:@"openning_amount"];
    
    [self post:params callback:callback withUrlAPI:nil];
}


#pragma mark - Daily Report
-(void)getDailyReport:(Callback)callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"report.dailyReport", @"method",nil];
    [self post:params callback:callback withUrlAPI:nil];
}


#pragma mark - Cash drawer management
-(void)getTransactionList:(Callback)callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"transaction.list", @"method",nil];
    [self post:params callback:callback withUrlAPI:nil];
}

-(void)addTransactionAmount:(NSString *)amount Note:(NSString *)note Type:(NSString *)type Callback:(Callback)callback
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"transaction.add", @"method",nil];
    [params setObject:amount forKey:@"amount"];
    [params setObject:note forKey:@"note"];
    [params setObject:type forKey:@"type"];
    
    [self post:params callback:callback withUrlAPI:nil];
}

-(void)getCurrentBalance:(Callback)callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"transaction.getCurrentBalance", @"method",nil];
    [self post:params callback:callback withUrlAPI:nil];
}


#pragma  mark - set store data
-(void)setStoreData:(NSString *)storeId TillId:(NSString *)tillId Callback:(Callback)callback
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"config.setStoreData", @"method",nil];
    [params setObject:storeId forKey:@"store_id"];
    [params setObject:tillId forKey:@"till_id"];
    
    [self post:params callback:callback withUrlAPI:nil];
}

#pragma mark- customer
-(void)getCustomer:(NSString *)searchKey Callback:(Callback)callback
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"customer.search", @"method",nil];
    [params setValue:@[searchKey, [NSNumber numberWithUnsignedInteger:1], [NSNumber numberWithUnsignedInteger:99999]] forKey:@"params"];
    [self post:params callback:callback withUrlAPI:nil];
}

#pragma mark - checkout_cart.holdOrder
-(void)holdOrderCashIn:(NSString *)cashIn Note:(NSString *)note Callback:(Callback)callback{
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"checkout_cart.holdOrder",@"method", nil];
    [params setObject:cashIn forKey:@"cashin"];
    [params setObject:note forKey:@"note"];
    DLog(@"params:%@",params);
    
    [self post:params callback:callback withUrlAPI:nil];
}

-(void)getCustomerGroups:(Callback)callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"customer.getCustomerGroups", @"method",nil];
    [self post:params callback:callback withUrlAPI:nil];
}

#pragma mark - change profile info
-(void)changeProfleUserId:(NSString*)userId Name:(NSString*)name Email:(NSString*)email OldPassword:(NSString*)oldPassword NewPassword:(NSString*)newPassword Callback:(Callback)callback{
    
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"user.update",@"method", nil];
    
    NSMutableDictionary * paramDict =[[NSMutableDictionary alloc] init];
    [paramDict setObject:name forKey:@"display_name"];
    [paramDict setObject:email forKey:@"email"];
    [paramDict setObject:oldPassword forKey:@"old_password"];
    [paramDict setObject:newPassword forKey:@"new_password"];
    
    NSArray * array =[[NSArray alloc] initWithObjects:userId,paramDict, nil];
    [params setObject:array forKey:@"params"];
    [self post:params callback:callback withUrlAPI:nil];
}

#pragma mark - Order Shipment
-(void)orderShipmentOrderId:(NSString *)incrementId WithItems:(NSDictionary *)items Callback:(Callback)callback{
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"order_shipment.create",@"method", nil];
    
    NSArray * array =[[NSArray alloc] initWithObjects:incrementId,items,@"",@"",@"", nil];
    [params setObject:array forKey:@"params"];
    
    [self post:params callback:callback withUrlAPI:nil];
    
}


#pragma mark - URL FIX CONSTANT
#pragma mark - Active Key
-(void)getStoreUrl:(NSString *)apiKey Callback:(Callback)callback{
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"getStoreUrl",@"method", nil];
    [params setObject:apiKey forKey:@"api_key"];
    
    [self post:params callback:callback withUrlAPI:URL_ACTIVE_KEY];
}

#pragma mark - Order Shipment
-(void)getOrderPrintLink:(NSString *)incrementId Callback:(Callback)callback{
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"order.getPrintLink",@"method", nil];
    NSArray * array =[[NSArray alloc] initWithObjects:incrementId, nil];
    [params setObject:array forKey:@"params"];
    [self post:params callback:callback withUrlAPI:nil];
}

#pragma mark - order.holdOrderContinue
-(void)holdOrderContinue:(NSString *)incrementId Callback:(Callback)callback{
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"order.holdOrderContinue",@"method", nil];
    NSArray * array =[[NSArray alloc] initWithObjects:incrementId, nil];
    [params setObject:array forKey:@"params"];
    [self post:params callback:callback withUrlAPI:nil];
}

-(void)requestTrial:(NSString *)email Domain:(NSString*)domain Callback:(Callback)callback{
    
    // PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
    NSString* requestId = @"";//[bindings stringForKey:KEY_DEVICE_TRIAL_ID];
    if(!requestId){
        requestId=@"";
    }
    
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"registerTrial",@"method", nil];
    [params setObject:email forKey:@"email"];
    [params setObject:domain forKey:@"domain"];
    [params setObject:requestId forKey:@"requestId"];
    [self post:params callback:callback withUrlAPI:URL_ACTIVE_KEY];
    
}

#pragma mark - Lay thong tin demo info
-(void)getDemoDataCallback:(Callback)callback{
    NSMutableDictionary * params =[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"getDemoData",@"method", nil];
    [self post:params callback:callback withUrlAPI:URL_ACTIVE_KEY];
}

@end
