//
//  RPOSNetworkManager.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"

@interface RetailerPosNetworkManager : NSObject
@property (nonatomic) BOOL reachable;
@property (nonatomic) BOOL isSecure;
@property (strong, nonatomic) NSMutableDictionary *headerParams;

+(RetailerPosNetworkManager *)sharedInstance;
- (void)requestWithMethod: (NSString *)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSMutableDictionary *)hearder;
- (void) removeCacheFromKey:(NSString*)url params:(NSMutableDictionary*)params;
- (void) removeCacheWithKeyWord:(NSString*)keyWord;
@end
