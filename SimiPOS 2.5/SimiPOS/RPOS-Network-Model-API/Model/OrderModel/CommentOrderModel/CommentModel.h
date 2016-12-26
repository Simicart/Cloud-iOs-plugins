//
//  CommentModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosModel.h"

@interface CommentModel : RetailerPosModel

/*
 Notification name: DidAddCommentOrder
 */
- (void)addCommentOrder:(NSString *)orderId withComment:(NSString*)comment;


@end
