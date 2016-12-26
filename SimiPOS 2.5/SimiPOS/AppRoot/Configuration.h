//
//  Configuration.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSMutableDictionary.h"

#import "RPCache.h"

#define kFileName   @"config"
#define kConfigKey  @"edf28a4c7d12d9539370c2be3ee3398c"

#define KEY_NAME_MAIN_URL @"main_url"
#define KEY_NAME_DEV_URL @"dev_url"

// version 1.4 22/07/16
#define URL_TRY_DEMO @"http://demo.magestore.com/retailerpos/webpos/api"
//#define URL_TRY_DEMO @"http://dev-extension.magestore.com/everest/magento19/index.php/webpos/api"
#define URL_ACTIVE_KEY @"http://www.magestore.com/posmanagement/api"
#define ACTIVE_KEY_DEMO @"pos57174bda3ee73"
#define MARKETING_URL @"http://www.magestore.com/retailer-pos.html"



@interface Configuration : MSMutableDictionary

@property (strong, nonatomic) NSMutableDictionary *globalAccess;
// lionel added to cache product.
@property (strong, nonatomic) RPCache *productCache;
@property (strong, nonatomic) NSCache *productCacheResult;
// end

//Ravi
@property (strong, nonatomic) NSMutableDictionary *configPrice;
//End
           
           

+ (NSObject *)getSingleton: (NSString *)modelClass;

+ (void)setSingleton:(NSString *)modelClass WithValue:(id)modelValue;

+ (NSObject *)getResource: (NSString *)resourceClass;

+ (Configuration *)globalConfig;

// lionel add to cache product
+ (RPCache *)productCache;
// end

+ (id)getConfig: (NSString *)key;

+ (BOOL)isDev;

+(NSString *)getActiveKeyDemo;

#pragma mark - Update MageStoreSever
- (void)readDomainFromActivateKey;

- (void)tryDemoDomain;

@end
