//
//  ModelAbstract.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/17/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSMutableDictionary.h"
#import "APIResource.h"

@interface ModelAbstract : MSMutableDictionary
@property (copy, nonatomic) NSString *resourceClass;
@property (copy, nonatomic) NSString *eventPrefix;

-(NSString *)getId;

// Update data for Model
-(ModelAbstract *)setData:(NSDictionary *)data;
-(ModelAbstract *)addData:(NSDictionary *)data;

// Working with Resource
-(NSObject <APIResource> *)getResource;
-(ModelAbstract *)load:(NSObject *)identify;
-(void)loadSuccess;

// Save data to server
-(void)save;
-(void)saveSuccess;

@end
