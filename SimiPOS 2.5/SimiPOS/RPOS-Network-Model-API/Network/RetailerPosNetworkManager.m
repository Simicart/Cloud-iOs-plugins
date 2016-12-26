//
//  RPOSNetworkManager.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosNetworkManager.h"

#import "RPCache.h"

@implementation RetailerPosNetworkManager

@synthesize reachable, headerParams, isSecure;

+ (RetailerPosNetworkManager *)sharedInstance{
    static RetailerPosNetworkManager *_shareInstance = nil;
    static dispatch_once_t onePredicate;
    dispatch_once(&onePredicate, ^{
        _shareInstance = [[RetailerPosNetworkManager alloc]init];
    });
    return _shareInstance;
}


- (id)init{
    self =[super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachable) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        isSecure = YES;
    }
    return self;
}

- (BOOL)reachable{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void) removeCacheFromKey:(NSString*)url params:(NSMutableDictionary*)params{
    Configuration *config = [Configuration globalConfig];
    RPCache *cache = config.productCache;
    NSString *keyCache = [NSString stringWithFormat:@"%@%@", url, params];
    [cache removeObjectForKey:keyCache];
}

- (void) removeCacheWithKeyWord:(NSString*)keyWord{
    Configuration *config = [Configuration globalConfig];
    RPCache *cache = config.productCache;

    for (NSString*key in [cache allKeys]) {
        if([key rangeOfString:keyWord].location != NSNotFound){
            [cache removeObjectForKey:key];
        }
    }
}

- (void)requestWithMethod:(NSString *)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSMutableDictionary *)header{
    
    Configuration *config = [Configuration globalConfig];
    NSString *param_method = [params objectForKey:@"method"];
    NSString *keyCache = [NSString stringWithFormat:@"%@%@", urlPath, params];
    RPCache *cache = config.productCache;
    
    if ([self allowCacheWithParamMethod:param_method]) {
        if([cache objectForKey:keyCache] != nil){
            if (target != nil && selector != nil) {
                if (target != nil && selector != nil) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:[cache objectForKey:keyCache]];
                }
            }
        }else{
            [self request:method urlPath:urlPath parameters:params target:target selector:selector header:header keyCache:keyCache cache:cache paramMethod:param_method];
        }
    }else{
        [self request:method urlPath:urlPath parameters:params target:target selector:selector header:header keyCache:keyCache cache:cache paramMethod:param_method];
    }
}

- (BOOL) checkParamMethod:(NSString*)paramMethod method:(NSString*)method{
    if([paramMethod rangeOfString:method].location != NSNotFound){
        return true;
    }
    return false;
}

- (void)request:(NSString *)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSMutableDictionary *)header keyCache:(NSString*)keyCache cache:(RPCache*)cache paramMethod:(NSString*)paramMethod{
    
    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc]init];
    
    //    if (isSecure) {
    //        if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
    ////            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //        }
    //    }
    
    if (header != nil) {
        for (NSString *key in [header allKeys]) {
            [request setValue:[header valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    //    NSLog(@"%@",[request HTTPRequestHeaders]);
    //    [request setValue:@"" forHTTPHeaderField:@"Accept-Language"];
    //    [request setValue:@"" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"YES" forHTTPHeaderField:@"Keep-Alive"];
    //    NSLog(@"%@",[request HTTPRequestHeaders]);
    
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager setRequestSerializer:request];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    [serializer setAcceptableContentTypes:nil];
    [operationManager setResponseSerializer:serializer];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        [operationManager POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Response String: %@", [operation responseString]);
            if (target != nil && selector != nil) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self addCacheWithObject:responseObject andKey:keyCache forCache:cache paramMethod:paramMethod];
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Request Error: %@", [error localizedDescription]);
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
            DLog(@"Failure: %@", error);
        }];
    }else if ([[method uppercaseString] isEqualToString:@"GET"]){
        
        
        [operationManager GET:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Response String: %@", [operation responseString]);
            if (target != nil && selector != nil) {
                [self addCacheWithObject:responseObject andKey:keyCache forCache:cache paramMethod:paramMethod];
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Request Error: %@", [error localizedDescription]);
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
        }];
    }else if ([[method uppercaseString] isEqualToString:@"PUT"]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        [operationManager PUT:urlPath parameters:string success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Response String: %@", [operation responseString]);
            if (target != nil && selector != nil) {
                [self addCacheWithObject:responseObject andKey:keyCache forCache:cache paramMethod:paramMethod];
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Request Error: %@", [error localizedDescription]);
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
        }];
    }else if ([[method uppercaseString] isEqualToString:@"DELETE"]){
        [operationManager DELETE:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Response String: %@", [operation responseString]);
            if (target != nil && selector != nil) {
                [self addCacheWithObject:responseObject andKey:keyCache forCache:cache paramMethod:paramMethod];
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            DLog(@"Request Error: %@", [error localizedDescription]);
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
        }];
    }

}
- (BOOL)allowCacheWithParamMethod: (NSString *)param_method{
    
    if ([self checkParamMethod:param_method method:@"product.list"] || [self checkParamMethod:param_method method:@"report.zreport"] || [self checkParamMethod:param_method method:@"report.dailyReport"] || [self checkParamMethod:param_method method:@"order.search"]) {
        return YES;
    }
    return NO;
}

- (void)addCacheWithObject : responseObject andKey:(NSString*)keyCache forCache:(RPCache*)cache paramMethod:(NSString*)paramMethod{
    if([self validateResponseForCache:responseObject]){
        [cache setObject:keyCache forKey:paramMethod];
        [cache setObject:responseObject forKey:keyCache];
    }
}

- (BOOL)validateResponseForCache: (id)responseObject{
    if ([responseObject isKindOfClass:[NSError class]]) {
        return NO;
    }else{
        NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([response valueForKey:@"success"]){
            if([[response valueForKey:@"success"] boolValue]){
                return YES;
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }
    return NO;
}
@end
