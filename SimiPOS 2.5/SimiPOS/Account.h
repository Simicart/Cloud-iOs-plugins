//
//  Account.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Account : ModelAbstract
@property (strong, nonatomic) NSArray *storeUrls;

+ (Account *)currentAccount;
- (BOOL)authorize:(NSString *)email andPassword:(NSString *)password;

#pragma mark - Refine Store URL
+ (NSString *)refineSimiPOSURL:(NSString *)storeUrl;

#pragma mark - Check Permission
+ (NSUInteger)permissionValue:(NSString *)action;

@end
