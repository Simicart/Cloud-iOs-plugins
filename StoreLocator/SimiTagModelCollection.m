//
//  SimiTagModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagModelCollection.h"
#import "SimiGlobalVar+StoreLocator.h"
#import "SimiTagAPI.h"

@implementation SimiTagModelCollection
- (void)getTagWithOffset:(NSString*)offset limit:(NSString*)limit
{
    currentNotificationName = @"DidFinishGetTagList";
    modelActionType = ModelActionTypeInsert;
    //Gin edit
    [self preDoRequest];
    //end
    [(SimiTagAPI *)[self getAPI] getTagListWithParams:@{@"offset":offset,@"limit":limit} target:self selector:@selector(didFinishRequest:responder:)];
}
@end
