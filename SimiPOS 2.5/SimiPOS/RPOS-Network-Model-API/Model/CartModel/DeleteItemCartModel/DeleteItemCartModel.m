//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "DeleteItemCartModel.h"
#import "DeleteItemCartAPI.h"

@implementation DeleteItemCartModel

- (void)deleteItemCartWidthId : (NSString*)productId{
    currentNotificationName = @"DidDeleteItemCart";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *method = @"checkout_product.remove";
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:method forKey:@"method"];
    [params setValue:productId forKey:@"params"];
    DLog(@"%@",params);
    
    [(DeleteItemCartAPI *) [self getAPI] deleteItemWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
