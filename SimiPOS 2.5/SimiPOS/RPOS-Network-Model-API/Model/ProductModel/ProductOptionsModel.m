//
//  ProductOptionsModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ProductOptionsModel.h"
#import "ProductOptionsAPI.h"

@implementation ProductOptionsModel

- (void)getProductOptionWithId:(NSString *)productId{
    currentNotificationName = @"DidGetProductOptions";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"product.options" forKey:@"method"];
    [params setValue:productId forKey:@"params"];
    
    [(ProductOptionsAPI *) [self getAPI] getProductOptionsWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
