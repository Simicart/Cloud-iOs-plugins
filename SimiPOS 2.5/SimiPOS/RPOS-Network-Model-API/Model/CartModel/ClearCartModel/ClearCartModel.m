//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ClearCartModel.h"
#import "ClearCartAPI.h"

@implementation ClearCartModel

- (void)clearCart{
    currentNotificationName = @"DidClearCart";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_product.clear" forKey:@"method"];
    DLog(@"%@",params);
    
    [(ClearCartAPI *) [self getAPI]clearCartWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
