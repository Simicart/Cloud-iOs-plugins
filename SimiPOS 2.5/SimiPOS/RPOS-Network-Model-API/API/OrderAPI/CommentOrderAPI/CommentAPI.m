//
//  CommentAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "CommentAPI.h"

@implementation CommentAPI

- (void)addCommentWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector{
    Configuration *config = [Configuration globalConfig];
    NSString *url = [config objectForKey:API_URL_NAME];
    [self requestWithMethod:method URL:url params:params target:target selector:selector header:nil];
}

@end
