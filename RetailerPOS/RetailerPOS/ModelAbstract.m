//
//  ModelAbstract.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/17/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"
#import "Configuration.h"
#import "APIResource.h"

@implementation ModelAbstract
@synthesize resourceClass = _resourceClass;
@synthesize eventPrefix = _eventPrefix;

-(NSString *)getId
{
    id identify = [self objectForKey:@"id"];
    if ([identify isKindOfClass:[NSNumber class]]) {
        return [identify stringValue];
    }
    return (NSString *)identify;
}

#pragma mark - update object
-(ModelAbstract *)setData:(NSDictionary *)data
{
    if ([self count]) {
        [self removeAllObjects];
    }
    [self addEntriesFromDictionary:data];
    return self;
}

-(ModelAbstract *)addData:(NSDictionary *)data
{
    [self addEntriesFromDictionary:data];
    return self;
}

#pragma mark - working with resource
-(NSObject <APIResource> *)getResource
{
    if (self.resourceClass != nil) {
        return (NSObject <APIResource> *)[Configuration getResource:self.resourceClass];
    }
    NSString *resourceClass = [[self class] description];
    return (NSObject <APIResource> *)[Configuration getResource:resourceClass];
}

-(ModelAbstract *)load:(NSObject *)identify
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadBefore" object:self];
    if (self.eventPrefix != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@LoadBefore", self.eventPrefix] object:self];
    }
    
    [[self getResource] load:self withId:identify finished:@selector(loadSuccess)];
    
    return self;
}

-(void)loadSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractLoadAfter" object:self];
    if (self.eventPrefix != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@LoadAfter", self.eventPrefix] object:self];
    }
}

#pragma mark - save data to server
- (void)save
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractSaveBefore" object:self];
    if (self.eventPrefix != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SaveBefore", self.eventPrefix] object:self];
    }
    
    if ([self getId]) {
        [[self getResource] save:self withAction:@"update" finished:@selector(saveSuccess)];
    } else {
        [[self getResource] save:self withAction:@"create" finished:@selector(saveSuccess)];
    }
}

- (void)saveSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelAbstractSaveAfter" object:self];
    if (self.eventPrefix != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SaveAfter", self.eventPrefix] object:self];
    }
}

@end
