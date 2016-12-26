//
//  CommentModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "CommentModel.h"
#import "CommentAPI.h"

@implementation CommentModel

- (void)addCommentOrder:(NSString *)orderId withComment:(NSString*)comment{
    
    currentNotificationName = @"DidAddCommentOrder";
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    NSMutableArray *paramsArr = [NSMutableArray new];
//    NSMutableDictionary *paramsDict = [NSMutableDictionary new];
    NSString *method = @"order.addComment";
    
    
    paramsArr = [[NSMutableArray alloc]init];
    [paramsArr addObject:orderId];
    if (comment) {
        [paramsArr addObject:comment];
    }else{
        [paramsArr addObject:@""];
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
    

    [(CommentAPI *) [self getAPI] addCommentWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}





@end
