//
//  SimiStoreLocatorDetailViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/3/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import "SimiStoreLocatorModel.h"
#import <MessageUI/MessageUI.h>

#define SIZE_SCROLL_VIEW_DETAIL ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 320 : 680)
@protocol SimiStoreLocatorDetailViewControllerDelegate <NSObject>
@optional
- (void)returnMapViewController:(SimiStoreLocatorModel*)sLModelParam;
@end

@interface SimiStoreLocatorDetailViewController : SimiViewController<MFMailComposeViewControllerDelegate>


@property (nonatomic, strong) SimiStoreLocatorModel *sLModel;
@property (nonatomic) float currentLatitude;
@property (nonatomic) float currentLongitude;

@property (nonatomic, strong)   UIScrollView *scrView;
@property (nonatomic, strong)   UILabel *lblStoreName;
@property (nonatomic, strong)   UILabel *lblStoreAddress;
@property (nonatomic, strong)   UIImageView *imgIconAddress;

@property (nonatomic, strong)   UIButton *btnStorePhone;
@property (nonatomic, strong)   UILabel *lblStorePhone;
@property (nonatomic, strong)   UIImageView *imgIconPhone;

@property (nonatomic, strong)   UIButton *btnStoreEmail;
@property (nonatomic, strong)   UILabel *lblStoreEmail;
@property (nonatomic, strong)   UIImageView *imgIconEmail;

@property (nonatomic, strong)   UIButton *btnStoreWebsite;
@property (nonatomic, strong)   UILabel *lblStoreWebSite;
@property (nonatomic, strong)   UIImageView *imgIconWebsite;


@property (nonatomic, strong)   UIImageView *imgStore;
@property (nonatomic, strong)   UILabel *lblGetdirection;
@property (nonatomic, strong)   UIButton *btnGetdirection;
@property (nonatomic, strong)   UIImageView *imgStoreBackground;
@property (nonatomic, strong)   UIButton *btnDirection;

@property (nonatomic, strong)   UIView *viewInfomation;
@property (nonatomic, strong)   UILabel *lblInfomationContents;
@property (nonatomic, strong)   UIButton *btnShowMoreLess;
@property (nonatomic, strong)   UIImageView *imgInformation;

@property (nonatomic, strong)   UIView *viewOpenHours;
@property (nonatomic, strong)   UIImageView *imgIconOpenHours;
@property (nonatomic, strong)  UILabel *lblOpenHours;
@property (nonatomic, strong)  UILabel *lblMonday;
@property (nonatomic, strong)  UILabel *lblTuesday;
@property (nonatomic, strong)  UILabel *lblWednesday;
@property (nonatomic, strong)  UILabel *lblThursday;
@property (nonatomic, strong)  UILabel *lblFriday;
@property (nonatomic, strong)  UILabel *lblSaturday;
@property (nonatomic, strong)  UILabel *lblSunday;
@property (nonatomic, strong)  UILabel *lblMondayContent;
@property (nonatomic, strong)  UILabel *lblTuesdayContent;
@property (nonatomic, strong)  UILabel *lblWednesdayContent;
@property (nonatomic, strong)  UILabel *lblThursdayContent;
@property (nonatomic, strong)  UILabel *lblFridayContent;
@property (nonatomic, strong)  UILabel *lblSaturdayContent;
@property (nonatomic, strong)  UILabel *lblSundayContent;

@property (nonatomic, weak) id<SimiStoreLocatorDetailViewControllerDelegate> delegate;

@property (nonatomic, strong)  UILabel *lblSpecialsDay;
@property (nonatomic, strong)  UIView *viewSpecialsDay;
@property (nonatomic, strong)  UILabel *lblSpecialsDayContent;
@property (nonatomic, strong)  UIImageView *imgIconSpecialDay;

@property (nonatomic, strong)  UILabel *lblHolidays;
@property (nonatomic, strong)  UIView *viewHolidays;
@property (nonatomic, strong)  UILabel *lblHolidaysContent;
@property (nonatomic, strong)  UIImageView *imgIconHolidays;


- (void)btnStorePhone_Click:(id)sender;
- (void)btnStoreEmail_Click:(id)sender;
- (void)btnStoreWebSite_Click:(id)sender;
- (void)btnShowMoreLess_Click:(id)sender;
- (void)btnGetDirections_Click:(id)sender;
- (void)btnViewMap_Click:(id)sender;

@end
