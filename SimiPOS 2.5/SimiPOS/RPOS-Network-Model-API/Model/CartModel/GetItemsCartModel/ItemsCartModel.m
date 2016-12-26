//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ItemsCartModel.h"
#import "ItemsCartAPI.h"

@implementation ItemsCartModel

- (void)getItemsCart{
    currentNotificationName = @"DidGetItemsCart";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_cart.items" forKey:@"method"];
    DLog(@"%@",params);
    
    [(ItemsCartAPI *) [self getAPI]getItemsCartWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
