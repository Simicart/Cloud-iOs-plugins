//
//  SimiModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/21/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosModel.h"

@implementation RetailerPosModel

+ (RetailerPosAPI *)getRetailerPosAPI
{
    NSString *klass = [NSStringFromClass(self) stringByReplacingOccurrencesOfString:@"Model" withString:@"API"];
    Class api = NSClassFromString(klass);
    Class loopClass = [self superclass];
    while (api == nil && loopClass) {
        api = NSClassFromString([[loopClass description] stringByReplacingOccurrencesOfString:@"Model" withString:@"API"]);
            loopClass = [loopClass superclass];
    }
    return [api new];
}

- (id)init
{
    self = [super init];
    if (self) {
        currentNotificationName = @"DidFinishRequest";
    }
    return self;
}

- (RetailerPosAPI *)getAPI{
    return [self.class getRetailerPosAPI];
}

- (void)setData:(NSDictionary *)data{
    if ([self count]) {
        [self removeAllObjects];
    }
    [self setValuesForKeysWithDictionary:data];
//    [self addEntriesFromDictionary:data];
}

- (void)addData:(NSDictionary *)data{
    [self addEntriesFromDictionary:data];
}

- (void)editData:(NSDictionary *)data{
    for (NSString *key in [data allKeys]) {
        if ([[self valueForKey:key] isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *origin = (NSMutableDictionary *)[self valueForKey:key];
            NSMutableDictionary *temp = (NSMutableDictionary *)[data valueForKey:key];
            for (NSString *childKey in [temp allKeys]) {
                [origin setValue:[temp valueForKey:childKey] forKey:childKey];
            }
        }else{
            [self setValue:[data valueForKey:key] forKey:key];
        }
    }
}

- (void)deleteData{
    [self removeAllObjects];
}

- (NSString *)currentNotificationName
{
    return currentNotificationName;
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(RetailerPosResponder *)responder{
    if (responder.retailerPosObjectName) {
        currentNotificationName = responder.retailerPosObjectName;
    }
     [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
    if ([responseObject isKindOfClass:[PosMutableDictionary class]]) {
        switch (modelActionType) {
            case ModelActionTypeInsert:{
                [self addData:(NSDictionary *)responseObject];
            }
                break;
            case ModelActionTypeEdit:{
                [self editData:(NSDictionary *)responseObject];
            }
                break;
            case ModelActionTypeDelete:{
                [self deleteData];
            }
                break;
            default:{
                [self setData:(NSDictionary *)responseObject];
            }
                break;
        }
        responder.data = [self objectForKey:@"data"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    if (![currentNotificationName isEqualToString:@"DidFinishRequest"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishRequest" object:self userInfo:@{@"responder":responder}];
    }
}

- (void)preDoRequest{
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@Before", currentNotificationName] object:self];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStart" object:currentNotificationName];
    if (![currentNotificationName isEqualToString:@"DidFinishRequest"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishRequest-Before" object:self];
    }
}

@end
