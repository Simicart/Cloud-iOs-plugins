//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "AddToCartModel.h"
#import "AddToCartAPI.h"

@implementation AddToCartModel

- (void)addToCartWidthProductId : (NSString*)productId options:(NSDictionary *)options{
    currentNotificationName = @"DidAddToCart";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    NSString *method = @"";
                                 
    if (options) {
        [paramsDict addEntriesFromDictionary:options];
    }
    if (productId != nil) {
        [paramsDict setValue:productId forKey:@"id"];
        method = @"checkout_product.add";
    }else{
        method = @"checkout_product.addCustom";
    }
    
    paramsArr = [[NSMutableArray alloc]initWithObjects:paramsDict, nil];
    for (NSString *key in [options allKeys]) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setValue:[options objectForKey:key] forKey:key];
        [paramsArr addObject:dict];
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
    
    [(AddToCartAPI *) [self getAPI] addToCartWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
