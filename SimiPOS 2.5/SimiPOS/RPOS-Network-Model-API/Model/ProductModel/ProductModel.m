//
//  CategoryModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ProductModel.h"
#import "ProductAPI.h"

@implementation ProductModel

- (void)getProduct:(NSString*)offset limit:(NSString*)limit category:(NSString*)categoryID keySearch:(NSString*)keyword{
    currentNotificationName = @"DidGetProduct";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *paramsKeySearchJson = @"";
    
    if(keyword != nil){
        NSString *paramKeyWord = [NSString stringWithFormat:@"%@%@%@", @"{\"like\":\"%", keyword, @"%\"}"];
        if(categoryID != nil){
            paramsKeySearchJson = [NSString stringWithFormat:@"%@%@%@%@", @"\"search\"", @":", paramKeyWord, @","];
        }else{
            paramsKeySearchJson = [NSString stringWithFormat:@"%@%@%@", @"\"search\"", @":" , paramKeyWord];
        }
    }
    
    NSString *paramsCategoryJson = @"";
    
    if(categoryID != nil){
        paramsCategoryJson = [NSString stringWithFormat:@"%@%@%@%@", @"\"category\"", @":\"", categoryID, @"\""];
    }
    
    NSString *paramCategory = [NSString stringWithFormat:@"%@%@%@%@", @"{", paramsKeySearchJson, paramsCategoryJson, @"}"];
    NSString *paramsProduct = [NSString stringWithFormat:@"[%@,%@,%@]", paramCategory, offset, limit ];
    
    DLog(@"ProductModel_ParamProduct:%@", paramsProduct);
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"product.list" forKey:@"method"];
    [params setValue:paramsProduct forKey:@"params"];
    
    [(ProductAPI *) [self getAPI] getProductWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
