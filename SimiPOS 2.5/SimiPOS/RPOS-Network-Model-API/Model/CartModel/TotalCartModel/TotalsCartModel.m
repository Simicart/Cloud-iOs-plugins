//
//  AddToCartModelCollection.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "TotalsCartModel.h"
#import "TotalsCartAPI.h"

@implementation TotalsCartModel

- (void)getTotalsCart{
    currentNotificationName = @"DidGetTotalsCart";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"checkout_cart.totals" forKey:@"method"];
    DLog(@"%@",params);
    
    [(TotalsCartAPI *) [self getAPI]getTotalsCartWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
