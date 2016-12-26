//
//  RetailerPosAPI.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RetailerPosNetworkManager.h"
//#import "NSObject+RetailerPosObject.h"

static NSString *POST = @"POST";
static NSString *GET = @"GET";
static NSString *DELETE = @"DELETE";
static NSString *PUT = @"PUT";

@interface RetailerPosAPI : NSObject

@property (strong, nonatomic) NSObject *target;
@property (nonatomic) SEL selector;

- (void)convertData:(id)responseObject;
- (void)requestWithMethod:(NSString*)medthod URL:(NSString *)url params:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header;

@end
