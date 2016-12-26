//
//  CategoryModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CategoryModel.h"
#import "CategoryAPI.h"

@implementation CategoryModel

- (void)getCategory{
    currentNotificationName = @"DidGetCategory";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"category.tree" forKey:@"method"];
    
    [(CategoryAPI *) [self getAPI] getCategoryWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
