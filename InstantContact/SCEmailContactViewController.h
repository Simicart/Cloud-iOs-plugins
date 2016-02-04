//
//  SCEmailContactViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import "SCListPhoneViewController.h"

//  Liam ADD 150504
static NSString *EMAILCONTACT_SECTIONMAIN = @"EMAILCONTACT_SECTIONMAIN";
static NSString *EMAILCONTACT_ROWWEBSITE = @"EMAILCONTACT_ROWWEBSITE";
static NSString *EMAILCONTACT_ROWCALL = @"EMAILCONTACT_ROWCALL";
static NSString *EMAILCONTACT_ROWMESSAGE = @"EMAILCONTACT_ROWMESSAGE";
static NSString *EMAILCONTACT_ROWEMAIL = @"EMAILCONTACT_ROWEMAIL";
//  End 150504
@interface SCEmailContactViewController : SimiViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCListPhoneViewController_Delegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UIButton *btnCall;
@property (nonatomic, strong) UIButton *btnEmail;
@property (nonatomic, strong) UIButton *btnWebsite;
@property (nonatomic, strong) UIButton *btnMessage;
@property (nonatomic, strong) UILabel *lblCall;
@property (nonatomic, strong) UILabel *lblEmail;
@property (nonatomic, strong) UILabel *lblWebsite;
@property (nonatomic, strong) UILabel *lblMessage;

@property (nonatomic, strong) UITableView *tblViewContent;
@property (nonatomic, strong) UICollectionView *colllectionViewContent;
@property (nonatomic) BOOL isCall;
@property (nonatomic, strong) SimiTable *cells;
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSMutableDictionary *contactModel;
//@property (nonatomic, strong) SCEmailContactModel *contactModel;

@end
