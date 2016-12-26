//
//  Configuration.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Configuration.h"
#import "NSData+AES256.h"
#import "UrlDomainConfig.h"

@interface Configuration()
- (NSString *)configFilePath;
@end

@implementation Configuration
@synthesize globalAccess = _globalAccess;

#pragma mark - config file path
- (NSString *)configFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:kFileName];
}

#pragma mark - singleton pattern
+ (NSObject *)getSingleton:(NSString *)modelClass
{
    NSString *classKey = [NSString stringWithFormat:@"model%@", modelClass];
    NSMutableDictionary *global = [[Configuration globalConfig] globalAccess];
    if ([global objectForKey:classKey] == nil) {
        [global setValue:[[NSClassFromString(modelClass) alloc] init] forKey:classKey];
    }
    return [global objectForKey:classKey];
}

+ (void)setSingleton:(NSString *)modelClass WithValue:(id)modelValue
{
    NSString *classKey = [NSString stringWithFormat:@"model%@", modelClass];
    NSMutableDictionary *global = [[Configuration globalConfig] globalAccess];
    [global setValue:modelValue forKey:classKey];
}

+ (NSObject *)getResource:(NSString *)resourceClass
{
    Configuration *globalConfig = [Configuration globalConfig];
    NSMutableDictionary *global = globalConfig.globalAccess;
    NSString *className = [NSString stringWithFormat:@"%@%@", [globalConfig objectForKey:@"store_type"], resourceClass];
    if ([global objectForKey:className] == nil) {
        [global setValue:[[NSClassFromString(className) alloc] init] forKey:className];
    }
    return [global objectForKey:className];
}

#pragma mark - global configuration and init config
+ (Configuration *)globalConfig
{
    static Configuration *globalConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalConfig = [[self alloc] init];
    });
    return globalConfig;
}

+ (id)getConfig:(NSString *)key
{
    return [[Configuration globalConfig] objectForKey:key];
}

+ (BOOL)isDev
{
    return NO;
}

- (id)init
{
    if (self = [super init]) {
        // Init global access for singleton pattern
        self.globalAccess = [[NSMutableDictionary alloc] init];
        
        [self setValue:@"Magento" forKey:@"store_type"];
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"quick_select"];
        [self setValue:MARKETING_URL forKey:@"magestore_buy_url"];
        
        //Demo
        if([Configuration isDev]){        
          [self tryDemoDomain];
           
        //Read database
        }else{
            [self readDomainFromActivateKey];
        }
    }
    return self;
}

- (void)tryDemoDomain
{
    [self setValue:URL_TRY_DEMO forKey:API_URL_NAME];
}

+(NSString *)getActiveKeyDemo{
    return ACTIVE_KEY_DEMO;
}

#pragma mark - Update MageStoreSever
- (void)readDomainFromActivateKey
{
    DLog(@" read domain");
    UrlDomainConfig * urlDomainConfig =[[UrlDomainConfig findAll] firstObject];
    if(urlDomainConfig){
        
        if([urlDomainConfig.domain_active isEqualToString:@"domain_live"]){
            [self setValue:urlDomainConfig.main_api_url forKey:API_URL_NAME];
            
        }else{
           [self setValue:urlDomainConfig.dev_api_url forKey:API_URL_NAME];
        }
        
    }
}

@end
