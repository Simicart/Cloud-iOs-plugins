//
//  MagentoAbstract.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSHTTPRequest.h"
#import "Configuration.h"
#import "APIResource.h"

@class ModelAbstract;
@class CollectionAbstract;

@interface MagentoAbstract : NSObject <APIResource>

-(void)login;
-(void)loginFinish:(ASIHTTPRequest *)request;

-(NSString *)sessionId;
-(BOOL)isLoggedIn;
-(void)logout;

-(void)post:(NSDictionary *)params target:(NSObject *)object finished:(SEL)finishedMethod async:(BOOL)aSync;

-(void)processError:(NSDictionary *)response forObject:(NSObject *)object;

#pragma mark - APIResource prepare load
-(NSMutableDictionary *)prepareLoad:(ModelAbstract *)model;
-(NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection;

#pragma mark - APIResource prepare save
-(NSMutableDictionary *)prepareSave:(ModelAbstract *)model withAction:(NSString *)action;

@end
