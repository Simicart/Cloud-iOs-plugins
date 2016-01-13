//
//  FacebookConnect.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiProductModel.h>
#import <SimiCartBundle/SCProductViewController.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>



@interface FacebookConnect : NSObject<UIWebViewDelegate>
@property (nonatomic, strong) SimiSection *section;
@property (nonatomic, strong) SimiProductModel *productModel;
@property (nonatomic, strong) SCProductMoreViewController *productMoreVC;

@property (nonatomic, strong) UIWebView *webComment;
@property (nonatomic, strong) UIButton *btnShare;
@property (nonatomic, strong) UIButton *btnComment;
@property (nonatomic, strong) NSString *stringHtml;
@property (nonatomic, strong) NSString *stringFacebookAppID;
@property (nonatomic) BOOL isShowComment;

@property (nonatomic, strong) UILabel *lblCountLike;
@property (nonatomic) int tagView;
@property (nonatomic) int tagFacebookView;
@property (nonatomic) BOOL isLoginWithComment;
@property (nonatomic, strong) UIButton *btnCommentWithOtherAccount;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL isHideTabBar;

@property (nonatomic, strong) UIButton *buttonFacebook;
@property (nonatomic, strong) UIView *facebookView;
@property (nonatomic, strong) FBSDKLikeButton *fbLikeButton;
@property (nonatomic) BOOL isShowFacebookView;

- (instancetype)initWithObject:(NSObject*)object;
@end
