//
//  SCFBConnectWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 11/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SCFBConnectWorker : NSObject<UIWebViewDelegate,FBSDKLoginButtonDelegate>
@property (nonatomic, strong) NSMutableArray *arrayFacebookConnect;
@end
