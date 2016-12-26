//
//  SimiModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/21/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "PosMutableDictionary.h"
#import "RetailerPosAPI.h"
#import "RetailerPosResponder.h"

typedef NS_ENUM(NSInteger, ModelActionType) {
    ModelActionTypeGet,    //0 - Get all data
    ModelActionTypeInsert, //1 - Get more and insert to last
    ModelActionTypeDelete, //2 - Delete all data
    ModelActionTypeEdit    //3 - Edit data
};

@interface RetailerPosModel : PosMutableDictionary{
    NSString *currentNotificationName;
    NSInteger modelActionType;
    BOOL isProcessingData;
}

+ (RetailerPosAPI *)getRetailerPosAPI;

- (RetailerPosAPI *)getAPI;

//Update model data
- (void)setData:(NSDictionary *)data;
- (void)addData:(NSDictionary *)data;
- (void)editData:(NSDictionary *)data;
- (void)deleteData;

/*
 Notification name: [NSString stringWithFormat:@"%@-Before", currentNotificationName]
 */
- (NSString *)currentNotificationName;
- (void)preDoRequest;
- (void)didFinishRequest:(NSObject *)responseObject responder:(RetailerPosResponder *)responder;

@end
