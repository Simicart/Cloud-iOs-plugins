//
//  SimiResponder.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+RetailerPosObject.h"

@interface RetailerPosResponder : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSMutableArray *message;
@property (strong, nonatomic) NSMutableArray *other;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSError *error;
//  Liam ADD 150316
@property (strong, nonatomic) NSDictionary *layerNavigation;
//  End 150316

- (NSString *)responseMessage;

@end
