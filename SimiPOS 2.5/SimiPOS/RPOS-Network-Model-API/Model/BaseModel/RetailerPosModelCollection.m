//
//  SimiModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/8/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosModelCollection.h"
#import "RetailerPosModel.h"

@implementation RetailerPosModelCollection

+ (RetailerPosAPI *)getRetailerPosAPI
{
    NSString *klass = [NSStringFromClass(self) stringByReplacingOccurrencesOfString:@"ModelCollection" withString:@"API"];
    Class api = NSClassFromString(klass);
    Class loopClass = [self superclass];
    while (api == nil && loopClass) {
        api = NSClassFromString([[loopClass description] stringByReplacingOccurrencesOfString:@"ModelCollection" withString:@"API"]);
        loopClass = [loopClass superclass];
    }
    return [api new];
}

- (id)init{
    self = [super init];
    if (self) {
        currentNotificationName = @"DidFinishRequest";
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in array) {
        RetailerPosModel *model = [self getModel];
        [model setData:obj];
        [temp addObject:model];
    }
    self = [super initWithArray:temp];
    return self;
}

- (void)setData:(PosMutableArray *)data{
    if ([self count]) {
        [self removeAllObjects];
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in data) {
        RetailerPosModel *model = [self getModel];
        [model setData:obj];
        [temp addObject:model];
    }
    [self addObjectsFromArray:temp];
}

- (void)addData:(PosMutableArray *)data{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in data) {
        RetailerPosModel *model = [self getModel];
        [model setData:obj];
        [temp addObject:model];
    }
    [self addObjectsFromArray:temp];
}

- (RetailerPosModel *)getModel{
    Class superClass = self.class;
    Class modelClass = NSClassFromString([[superClass description] stringByReplacingOccurrencesOfString:@"Collection" withString:@""]);
    while (modelClass == nil) {
        superClass = [superClass superclass];
        modelClass = NSClassFromString([[superClass description] stringByReplacingOccurrencesOfString:@"Collection" withString:@""]);
    }
    return [modelClass new];
}

- (RetailerPosAPI *)getAPI{
    return [self.class getRetailerPosAPI];
}

- (NSString *)currentNotificationName
{
    return currentNotificationName;
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(RetailerPosResponder *)responder{
//    if (responder.simiObjectName) {
//        currentNotificationName = responder.simiObjectName;
//    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
    if ([responseObject isKindOfClass:[PosMutableArray class]]) {
        switch (modelActionType) {
            case ModelActionTypeInsert:{
                [self addData:(PosMutableArray *)responseObject];
            }
                break;
            default:{
                [self setData:(PosMutableArray *)responseObject];
            }
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }else if (responseObject == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }
}

- (void)preDoRequest{
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@Before", currentNotificationName] object:self];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStart" object:currentNotificationName];
}

@end
