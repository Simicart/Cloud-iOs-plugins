//
//  SimiModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/8/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "PosMutableArray.h"
#import "RetailerPosModel.h"
#import "RetailerPosAPI.h"
#import "RetailerPosResponder.h"

@interface RetailerPosModelCollection : PosMutableArray{
    NSString *currentNotificationName;
    NSInteger modelActionType;
    BOOL isProcessingData;
}

+ (RetailerPosAPI *)getRetailerPosAPI;

- (RetailerPosAPI *)getAPI;

//Action for collection model data
- (void)setData:(NSArray *)data;
- (void)addData:(NSArray *)data;

/*
 Notification name: [NSString stringWithFormat:@"%@-Before", currentNotificationName]
 */
- (NSString *)currentNotificationName;
- (void)preDoRequest;
- (void)didFinishRequest:(NSObject *)responseObject responder:(RetailerPosResponder *)responder;
@end
