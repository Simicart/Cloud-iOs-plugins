//
//  MagentoAbstract.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"
#import "ModelAbstract.h"
#import "MagentoAbstract.h"
#import "Quote.h"
#import "APIManager.h"

@implementation MagentoAbstract

-(void)login
{
    Configuration *config = [Configuration globalConfig];
    NSURL *url = [NSURL URLWithString:[config objectForKey:API_URL_NAME]];
    
    MSHTTPRequest *request = [MSHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:60];
    __weak MSHTTPRequest *request_temp = request;
    
    [request addPostValue:@"login" forKey:@"method"];
    [request addPostValue:[config objectForKey:@"username"] forKey:@"username"];
    [request addPostValue:[config objectForKey:@"password"] forKey:@"password"];
    
    [request setCompletionBlock:^{
        if ([Configuration isDev]) {
            DLog(@"%@", [request_temp responseString]);
        }
        [self loginFinish: request_temp];
    }];
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"LoginNetworkFail", @"name", NSLocalizedString(@"Login failed!", nil), @"reason", nil]];
        [[Configuration globalConfig] removeObjectForKey:@"session"];
    }];
    [request startSynchronous];
}

-(void)loginFinish:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    if (result == nil || ![result isKindOfClass:[NSDictionary class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"ResponseStructureError", @"name", NSLocalizedString(@"Invalid response data structure", nil), @"reason", nil]];
    } else if (  [result objectForKey:@"success"] &&  [[result objectForKey:@"success"] boolValue] == YES) {
        [[Configuration globalConfig] setValue:[result objectForKey:@"data"] forKey:@"session"];
        // Re-assign quote id for current device
        if ([[Configuration globalConfig] objectForKey:@"quote_id"]
            // && ![[[Configuration globalConfig] objectForKey:@"quote_id"] isEqualToString:[[Quote sharedQuote] getId]]
        ) {
            NSDictionary *params = @{
                @"method": @"checkout_cart.id",
                @"params": [[Configuration globalConfig] objectForKey:@"quote_id"]
            };
            [self post:params target:nil finished:nil async:NO];
        }
    } else {
        [[Configuration globalConfig] removeObjectForKey:@"session"];
        [self processError:result forObject:nil];
    }
}

-(NSString *)sessionId
{
    return [[Configuration globalConfig] objectForKey:@"session"];
}

-(BOOL)isLoggedIn
{
    if ([self sessionId]) {
        return YES;
    }
    return NO;
}

-(void)logout
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"logout", @"method", nil];
    [self post:params target:nil finished:nil async:YES];
}

-(void)post:(NSDictionary *)params target:(NSObject *)object finished:(SEL)finishedMethod async:(BOOL)aSync
{
    /*
    APIManager * apiManager =[[APIManager alloc] init];
    [apiManager post:params callback:^(BOOL success, id result) {
        
        NSLog(@"params: %@",params);
        NSLog(@"result: %@",result);
        
        if (result == nil || ![result isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"ResponseStructureError", @"name", NSLocalizedString(@"Invalid response data structure", nil), @"reason", nil];
            if (object != nil) {
                [userInfo setValue:object forKey:@"model"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:userInfo];
        } else if ([result objectForKey:@"success"] && [[result objectForKey:@"success"] boolValue] == YES) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            // Working with response data
            if (object == nil) {
                // Do nothing
            } else if ([object isKindOfClass:[ModelAbstract class]]) {
                // Update data for model
                if ([[result objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                    [(ModelAbstract *)object addData:[result objectForKey:@"data"]];
                } else if (![(ModelAbstract *)object getId] && ![[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                    [object setValue:[result objectForKey:@"data"] forKey:@"id"];
                }
                if (finishedMethod != nil) {
                    [object performSelector:finishedMethod withObject:result];
                }
            } else if ([object isKindOfClass:[CollectionAbstract class]]) {
                // Update data for collection (by call back)
                if (finishedMethod != nil) {
                    [object performSelector:finishedMethod withObject:[result objectForKey:@"data"]];
                }
            } else if ([object isKindOfClass:[NSMutableDictionary class]]) {
                [(NSMutableDictionary *)object addEntriesFromDictionary:[result objectForKey:@"data"]];
            } else if ([object isKindOfClass:[NSMutableArray class]]) {
                [(NSMutableArray *)object addObjectsFromArray:[result objectForKey:@"data"]];
            }
#pragma clang diagnostic pop
        } else {
            [self processError:result forObject:object];
        }
        
    } withUrlAPI:nil];
    
    return;
    */
    
    Configuration *config = [Configuration globalConfig];
    NSURL *url = [NSURL URLWithString:[config objectForKey:API_URL_NAME]];
    
    // Johan : Log API request
    NSString *api = [url absoluteString];
    DLog(@"API Request: %@ and params : %@", api, params);
    // end
    NSString *method = [params objectForKey:@"method"];
    // lionel editted for cache product.
    // only cache with product
    if ([method rangeOfString:@"product"].location != NSNotFound) {
        if ([config.productCache objectForKey:[NSString stringWithFormat:@"%@%@", url, params]] != nil) {
            [[config.productCache objectForKey:[NSString stringWithFormat:@"%@%@", url, params]] performSelector:finishedMethod withObject:[config.productCacheResult objectForKey:[NSString stringWithFormat:@"%@%@", url, params]]];
        } else {
            MSHTTPRequest *request = [MSHTTPRequest requestWithURL:url];
            if ([[params objectForKey:@"method"] isEqualToString:@"checkout_cart.createOrder"]) {
                [request setTimeOutSeconds:120];
            } else {
                [request setTimeOutSeconds:60];
            }
            __weak MSHTTPRequest *request_temp = request;
            //Ravi
//            [request.requestHeaders setValue:@"YES"  forKey:@"Keep-alive"];
//            [request addRequestHeader:@"Keep-alive" value:@"YES"];
            //End
            [request addPostValue:[config objectForKey:@"session"] forKey:@"session"];
            if (params != nil) {
                // Johan: Log param request server
                NSData *paramData = [NSJSONSerialization  dataWithJSONObject:params options:0 error:nil];
                NSString *paramRequestToServer = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
                DLog(@"Param Request: %@", paramRequestToServer);
                // end
                
                [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([obj isKindOfClass:[NSData class]]) {
                        [request setData:obj withFileName:[NSString stringWithFormat:@"%@.png", key] andContentType:@"image/png" forKey:key];
                    } else if ([obj isKindOfClass:[NSArray class]]
                               || [obj isKindOfClass:[NSDictionary class]]) {
                        
                        NSString * jsonValue =[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
                        
                        [request addPostValue:jsonValue forKey:key];
                        
                    } else {
                        [request addPostValue:obj forKey:key];
                    }
                }];
            }
            [request setCompletionBlock:^{
                // Complete block
                NSData *responseData = [request_temp responseData];
                
                // Johan: Log data respone from server
                NSString *dataResqponeToServer = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                DLog(@"Data Respone: %@", dataResqponeToServer);
                // end
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                if (result == nil || ![result isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"ResponseStructureError", @"name", NSLocalizedString(@"Invalid response data structure", nil), @"reason", nil];
                    if (object != nil) {
                        [userInfo setValue:object forKey:@"model"];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:userInfo];
                } else if ([result objectForKey:@"success"] && [[result objectForKey:@"success"] boolValue] == YES) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    // Working with response data
                    if (object == nil) {
                        // Do nothing
                    } else if ([object isKindOfClass:[ModelAbstract class]]) {
                        // Update data for model
                        if ([[result objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                            [(ModelAbstract *)object addData:[result objectForKey:@"data"]];
                        } else if (![(ModelAbstract *)object getId] && ![[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                            [object setValue:[result objectForKey:@"data"] forKey:@"id"];
                        }
                        if (finishedMethod != nil) {
                            [object performSelector:finishedMethod withObject:result];
                        }
                    } else if ([object isKindOfClass:[CollectionAbstract class]]) {
                        // Update data for collection (by call back)
                        if (finishedMethod != nil) {
//                             lionel add to cache product
//                             check data.count before add to cache
                            if ([[result objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                                NSDictionary *data = [result objectForKey:@"data"];
                                NSNumber *total = [data valueForKey:@"total"];
                                if (total.integerValue != 0) {
                                    [config.productCache setObject:object forKey:[NSString stringWithFormat:@"%@%@", url, params]];
                                    [config.productCacheResult setObject:[result objectForKey:@"data"] forKey:[NSString stringWithFormat:@"%@%@", url, params]];
                                }
                            } else if ([[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                                NSArray *data = [result objectForKey:@"data"];
                                if (data.count != 0) {
                                    [config.productCache setObject:object forKey:[NSString stringWithFormat:@"%@%@", url, params]];
                                    [config.productCacheResult setObject:[result objectForKey:@"data"] forKey:[NSString stringWithFormat:@"%@%@", url, params]];
                                }
                            }
                            // end
                            [object performSelector:finishedMethod withObject:[result objectForKey:@"data"]];
                        }
                    } else if ([object isKindOfClass:[NSMutableDictionary class]]) {
                        [(NSMutableDictionary *)object addEntriesFromDictionary:[result objectForKey:@"data"]];
                    } else if ([object isKindOfClass:[NSMutableArray class]]) {
                        [(NSMutableArray *)object addObjectsFromArray:[result objectForKey:@"data"]];
                    }
#pragma clang diagnostic pop
                } else {
                    [self processError:result forObject:object];
                }
                // End Complete request block
            }];
            
            [request setFailedBlock:^{
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"PostNetworkFail", @"name", NSLocalizedString(@"Request to server fail", nil), @"reason", nil];
                if (object != nil) {
                    [userInfo setValue:object forKey:@"model"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:userInfo];
            }];
            if (aSync) {
                [request startAsynchronous];
            } else {
                [request startSynchronous];
            }
        }
    } else {
        MSHTTPRequest *request = [MSHTTPRequest requestWithURL:url];
        if ([[params objectForKey:@"method"] isEqualToString:@"checkout_cart.createOrder"]) {
            [request setTimeOutSeconds:120];
        } else {
            [request setTimeOutSeconds:60];
        }
        __weak MSHTTPRequest *request_temp = request;
        //Ravi
//        [request.requestHeaders setValue:@"YES"  forKey:@"Keep-alive"];
//        [request addRequestHeader:@"Keep-alive" value:@"YES"];
        //End
        
        [request addPostValue:[config objectForKey:@"session"] forKey:@"session"];
        if (params != nil) {
            // Johan: Log param request server
            NSData *paramData = [NSJSONSerialization  dataWithJSONObject:params options:0 error:nil];
            NSString *paramRequestToServer = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
            DLog(@"Param Request: %@", paramRequestToServer);
            // end
            
            [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSData class]]) {
                    [request setData:obj withFileName:[NSString stringWithFormat:@"%@.png", key] andContentType:@"image/png" forKey:key];
                } else if ([obj isKindOfClass:[NSArray class]]
                           || [obj isKindOfClass:[NSDictionary class]]) {
                    
                    NSString * jsonValue =[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
                    
                    [request addPostValue:jsonValue forKey:key];
                    
                } else {
                    [request addPostValue:obj forKey:key];
                }
            }];
        }
        [request setCompletionBlock:^{
            // Complete block
            NSData *responseData = [request_temp responseData];
            
            // Johan: Log data respone from server
            NSString *dataResqponeToServer = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DLog(@"Data Respone: %@", dataResqponeToServer);
            // end
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
            
            if (result == nil || ![result isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"ResponseStructureError", @"name", NSLocalizedString(@"Invalid response data structure", nil), @"reason", nil];
                if (object != nil) {
                    [userInfo setValue:object forKey:@"model"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:userInfo];
            } else if ([result objectForKey:@"success"] && [[result objectForKey:@"success"] boolValue] == YES) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                // Working with response data
                if (object == nil) {
                    // Do nothing
                } else if ([object isKindOfClass:[ModelAbstract class]]) {
                    // Update data for model
                    if ([[result objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                        [(ModelAbstract *)object addData:[result objectForKey:@"data"]];
                    } else if (![(ModelAbstract *)object getId] && ![[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                        [object setValue:[result objectForKey:@"data"] forKey:@"id"];
                    }
                    if (finishedMethod != nil) {
                        [object performSelector:finishedMethod withObject:result];
                    }
                } else if ([object isKindOfClass:[CollectionAbstract class]]) {
                    // Update data for collection (by call back)
                    if (finishedMethod != nil) {
                        [object performSelector:finishedMethod withObject:[result objectForKey:@"data"]];
                    }
                } else if ([object isKindOfClass:[NSMutableDictionary class]]) {
                    [(NSMutableDictionary *)object addEntriesFromDictionary:[result objectForKey:@"data"]];
                } else if ([object isKindOfClass:[NSMutableArray class]]) {
                    [(NSMutableArray *)object addObjectsFromArray:[result objectForKey:@"data"]];
                }
#pragma clang diagnostic pop
            } else {
                [self processError:result forObject:object];
            }
            // End Complete request block
        }];
        
        [request setFailedBlock:^{
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"PostNetworkFail", @"name", NSLocalizedString(@"Request to server fail", nil), @"reason", nil];
            if (object != nil) {
                [userInfo setValue:object forKey:@"model"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:userInfo];
        }];
        if (aSync) {
            [request startAsynchronous];
        } else {
            [request startSynchronous];
        }
    }
    // lionel end
}

-(void)processError:(NSDictionary *)response forObject:(NSObject *)object
{
    NSInteger error = [[response objectForKey:@"error"] integerValue];
    NSString *name;
    NSString *reason = [response objectForKey:@"data"];
    if (error == 0) {
        name = @"UnknowError";
    } else if (error == 1) {
        name = @"DisabledPOS";
    } else if (error == 3) {
        name = @"AccessDenied";
    } else if (error == 12) {
        // Session Expired - Need try to relogin (if has user and password)
        Configuration *config = [Configuration globalConfig];
        if ([config objectForKey:@"username"] && [config objectForKey:@"password"]) {
            [self login];
        }
//        return;
    } else if (error == 14) {
        name = @"SessionExpired";
    } else if (error == 13 || error == 15) {
        name = @"UnableLogin";
    } else {
        name = @"GeneralError";
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"name", reason, @"reason", nil];
    if (object != nil) {
        [userInfo setValue:object forKey:@"model"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:userInfo];
}

#pragma mark - APIResource load methods
-(NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    return [[NSMutableDictionary alloc] init];
}

-(void)load:(ModelAbstract *)object withId:(NSObject *)identify finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [self prepareLoad:object];
    if (identify) {
        [params setValue:@[identify] forKey:@"params"];
    }
    [self post:params target:object finished:finishedMethod async:NO];
}


-(NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (collection.conditions == nil) {
        collection.conditions = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *functionParams = [[NSMutableArray alloc] initWithObjects:collection.conditions, [NSNumber numberWithUnsignedInteger: collection.curPage], [NSNumber numberWithUnsignedInteger: collection.pageSize], nil];
    [params setValue:functionParams forKey:@"params"];
    return params;
}

-(void)loadCollection:(CollectionAbstract *)collection finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [self prepareLoadCollection:collection];
    [self post:params target:collection finished:finishedMethod async:NO];
}

#pragma mark - APIResource save method
-(NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action
{
    return [[NSMutableDictionary alloc] init];
}

-(void)save:(ModelAbstract *)object withAction:(NSString *)action finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [self prepareSave:object withAction:action];
    [self post:params target:object finished:finishedMethod async:NO];
}

@end
