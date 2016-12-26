//
//  UpdateItemCartModel.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "UpdateItemCartModel.h"
#import "UpdateItemCartAPI.h"

@implementation UpdateItemCartModel

- (void)updateItemCartWithID:(NSString *)productId options:(NSDictionary *)options qty:(NSString *)qty price:(NSString *)price{
    currentNotificationName = @"DidUpdateItemCart";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSMutableArray *paramsArr = [NSMutableArray new];
//    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    NSString *method = @"";
    paramsArr = [[NSMutableArray alloc]initWithObjects:productId, nil];
    if (options) {
        [paramsArr addObject:options];
        method = @"checkout_product.update";
    }else if(qty){
        [paramsArr addObject:qty];
        method = @"checkout_product.qty";
    } else if (price){
        [paramsArr addObject:price];
        method = @"checkout_product.price";
    }
    
//    for (NSString *key in [options allKeys]) {
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        [dict setValue:[options objectForKey:key] forKey:key];
//        [paramsArr addObject:dict];
//    }
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
    
    [(UpdateItemCartAPI *) [self getAPI] updateItemCartWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
