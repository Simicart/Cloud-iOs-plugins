//
//  Account.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "Account.h"
#import "Configuration.h"
#import "MagentoAccount.h"

@interface Account ()
- (void)refineSubAccount;
- (void)refineMainAccount;
@end

@implementation Account
@synthesize storeUrls = _storeUrls;

- (id)init
{        
    if (self = [super init]) {
        self.eventPrefix = @"Account";
    }
    return self;
}

+ (Account *)currentAccount
{
    NSMutableDictionary *global = [Configuration globalConfig].globalAccess;
    if ([global objectForKey:@"modelAccount"] == nil) {
        [global setValue:[Account new] forKey:@"modelAccount"];
    }
    return (Account *)[Configuration getSingleton:@"Account"];
}

#pragma mark - authorize user
- (BOOL)authorize:(NSString *)email andPassword:(NSString *)password
{
    self.storeUrls = nil;
    [self setValue:email forKey:@"email"];
    [self setValue:password forKey:@"password"];
    
    MagentoAccount *resource = (MagentoAccount *)[self getResource];
    [resource authorize:self];
    
    if ( [self objectForKey:@"success"] && [[self objectForKey:@"success"] boolValue]) {
        return YES;
    }

    if ([self objectForKey:@"is_subaccount"] != nil) {
        // Refine Data for Account
        if ([[self objectForKey:@"is_subaccount"] boolValue]) {
            [self refineSubAccount];
        } else {
            [self refineMainAccount];
        }
        return YES;
    }
    return NO;
}

- (void)refineSubAccount
{
    NSMutableArray *urls = [NSMutableArray new];
    NSDictionary *storeUrls = [self objectForKey:API_URL_NAME];
    if ([storeUrls objectForKey:@"lives"] && [[storeUrls objectForKey:@"lives"] isKindOfClass:[NSArray class]]) {
        for (NSString *url in [storeUrls objectForKey:@"lives"]) {
            NSString *refinedUrl = [[self class] refineRetailerPOSURL:url];
            if (refinedUrl) {
                [urls addObject:@{
                    @"store_url": refinedUrl,
                    @"store_plan": @"live"
                }];
            }
        }
        [self removeObjectForKey:@"lives"];
    }
    if ([storeUrls objectForKey:@"devs"] && [[storeUrls objectForKey:@"devs"] isKindOfClass:[NSArray class]]) {
        for (NSString *url in [storeUrls objectForKey:@"devs"]) {
            NSString *refineUrl = [[self class] refineRetailerPOSURL:url];
            if (refineUrl) {
                [urls addObject:@{
                    @"store_url": refineUrl,
                    @"store_plan": @"dev"
                }];
            }
        }
        [self removeObjectForKey:@"devs"];
    }
    self.storeUrls = urls;
}

- (void)refineMainAccount
{
    NSMutableArray *urls = [NSMutableArray new];
    NSDictionary *terms = [self objectForKey:@"terms"];
    [terms enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // Live domain
        NSString *liveUrl = [[self class] refineRetailerPOSURL:[obj objectForKey:@"live_domain"]];
        if (liveUrl != nil && ![liveUrl isEqualToString:@""]) {
            [urls addObject:@{
                @"store_url": liveUrl,
                @"store_plan": @"live",
                @"trial_type": [obj objectForKey:@"type"],
                @"expire_on": [obj objectForKey:@"expire_on"]
            }];
        }
        // Dev domain
        NSString *devUrl = [[self class] refineRetailerPOSURL:[obj objectForKey:@"dev_domain"]];
        if (devUrl != nil && ![devUrl isEqualToString:@""]) {
            [urls addObject:@{
                @"store_url": devUrl,
                @"store_plan": @"dev",
                @"trial_type": [obj objectForKey:@"type"],
                @"expire_on": [obj objectForKey:@"expire_on"]
            }];
        }
    }];
    [self removeObjectForKey:@"terms"];
    self.storeUrls = urls;
}

#pragma mark - refine store URL
+ (NSString *)refineRetailerPOSURL:(NSString *)storeUrl
{
    if (storeUrl == nil || [storeUrl length] < 5) {
        return nil;
    }
    // HTTP OR HTTPS
    if ([storeUrl rangeOfString:@"http"].location == NSNotFound) {
        storeUrl = [@"http://" stringByAppendingString:storeUrl];
    }
    // Check Index.php
    NSUInteger location = [storeUrl rangeOfString:@"/index.php"].location;
    if (location != NSNotFound) {
        storeUrl = [storeUrl substringToIndex:location+10];
    }
    // Remove Admin
    location = [storeUrl rangeOfString:@"/admin"].location;
    if (location != NSNotFound) {
        storeUrl = [storeUrl substringToIndex:location];
    }
    return [storeUrl stringByAppendingString:@"/RetailerPOS"];
}

#pragma mark - Check Permission
+ (NSUInteger)permissionValue:(NSString *)action
{
    Account *account = [self currentAccount];
    if ([[account objectForKey:@"user_role"] integerValue] == 1) {
        // Allowed all for Admin
        return 2;
    }
    NSDictionary *permission = [account objectForKey:@"role_permission"];
    if ([permission respondsToSelector:@selector(objectForKey:)]) {
        return [[permission objectForKey:action] integerValue];
    }
    return 0; // Default Value
}

@end
