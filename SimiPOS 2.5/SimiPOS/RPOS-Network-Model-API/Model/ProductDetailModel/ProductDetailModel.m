//
//  ProductDetailModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ProductDetailModel.h"
#import "ProductDetailAPI.h"

@implementation ProductDetailModel

- (void)getProductDetail:(NSString*)productID{
    currentNotificationName = @"DidGetProductDetail";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"product.detail" forKey:@"method"];
    [params setValue:productID forKey:@"params"];
    
    [(ProductDetailAPI *) [self getAPI] getProductDetailWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
