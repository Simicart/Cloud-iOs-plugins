//
//  SCStoreListTableViewCell.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import <SimiCartbundle/SimiGlobalVar.h>
#import "SimiStoreLocatorModel.h"
#import "UILabel+DynamicSizeMe.h"
@protocol SCStoreListTableViewCellDelegate
@optional
- (void)sendEmailToStoreWithEmail:(NSString *)email andEmailContent:(NSString*)emailContent;
- (void)choiceStoreLocatorWithStoreLocatorModel:(SimiStoreLocatorModel*)storeLM;

@end

@interface SCStoreListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *lblStoreName;
@property (nonatomic, strong) UILabel *lblStoreAddress;
@property (nonatomic, strong) UILabel *lblStoreDistance;
@property (nonatomic, strong) UIImageView* imgStoreImage;
@property (nonatomic, strong) UIImageView* imgBackground;

@property (nonatomic, strong) UILabel *lblCall;
@property (nonatomic, strong) UILabel *lblMail;
@property (nonatomic, strong) UILabel *lblMap;
@property (nonatomic, strong) UIButton* btnCall;
@property (nonatomic, strong) UIButton* btnMail;
@property (nonatomic, strong) UIButton* btnMap;
@property (nonatomic, strong) SimiStoreLocatorModel *storeLocatorModel;
@property (nonatomic, weak) id<SCStoreListTableViewCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andStoreData:(SimiStoreLocatorModel*)storeLocatorModel_;
- (void)btnCall_Click:(id)sender;
- (void)btnMail_Click:(id)sender;
- (void)btnMap_Click:(id)sender;

@end
