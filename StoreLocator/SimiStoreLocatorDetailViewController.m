//
//  SimiStoreLocatorDetailViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/3/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorDetailViewController.h"
#import "UILabel+DynamicSizeMe.h"
#import <SimiCartBundle/UIImageView+WebCache.h>
@interface SimiStoreLocatorDetailViewController ()

@end

@implementation SimiStoreLocatorDetailViewController
{
    float heightScrViewContentSize;
    float heightLableInformationRaise;
    BOOL isShowMore;
    BOOL haveSpecialsDay;
    BOOL haveHolidays;
    
    float sizeIcon; // sice icon
    float sizeStoreImage; //  size map
    float space; // Khoang cach line cac label
    float edgeSpace; // Khoang cach hai mep view
    float heightLabel;
    float heightButton;
    float widthContent;
    
    float labelTitleX;
    float widthTitle;
    float labelValueX;
    float widthValue;
    float heightOpenHourView;
}
@synthesize viewInfomation, viewOpenHours, viewSpecialsDay, viewHolidays;
@synthesize lblOpenHours,lblInfomationContents,lblFriday,lblFridayContent,lblMonday,lblMondayContent,lblSaturday,lblSaturdayContent,lblStoreAddress,lblStoreEmail,lblStoreName,lblStorePhone,lblStoreWebSite,lblSunday,lblSundayContent,lblThursday,lblThursdayContent,lblTuesday,lblTuesdayContent,lblWednesday,lblWednesdayContent, lblSpecialsDay, lblSpecialsDayContent, lblHolidays, lblHolidaysContent, lblGetdirection;
@synthesize scrView, imgStore, btnShowMoreLess, imgIconAddress;
@synthesize sLModel, delegate, currentLatitude, currentLongitude;
@synthesize imgStoreBackground, btnDirection, imgIconPhone;
@synthesize btnStorePhone;

#pragma mark View Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    scrView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    widthContent = CGRectGetWidth(scrView.frame);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        widthContent = 680;
    }
    [scrView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:scrView];
    heightScrViewContentSize = 5;

    sizeIcon = 20; // sice icon
    sizeStoreImage = 100; //  size map
    space = 5; // Khoang cach line cac label
    edgeSpace = 10; // Khoang cach hai mep view
    heightLabel = 20;
    heightButton = 30;
    
    [self initStoreName];
    [self initGoogleImage];
    [self initStoreAddress];
    [self initStorePhone];
    [self initStoreEmail];
    [self initStoreWebsite];
    [self initStoreInformation];
    [self initStoreOpenHour];
    [self initStoreSpecialDays];
    [self initStoreHolidays];
    
    [scrView setContentSize:CGSizeMake(SIZE_SCROLL_VIEW_DETAIL, heightScrViewContentSize)];
    [super viewDidLoadBefore];
}

- (void)initStoreName
{
    lblStoreName = [[UILabel alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, heightLabel)];
    [lblStoreName setTextColor:[UIColor colorWithRed:243.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1.0]];
    [lblStoreName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE + 4]];
    [lblStoreName setLineBreakMode:NSLineBreakByWordWrapping];
    if ([sLModel valueForKey:@"name"]) {
        [lblStoreName setText:[sLModel valueForKey:@"name"]];
        [lblStoreName resizeToFit];
        [scrView addSubview:lblStoreName];
        heightScrViewContentSize += CGRectGetHeight(lblStoreName.frame) + space;
    }
}

- (void)initGoogleImage
{
    imgStore = [[UIImageView alloc]initWithFrame:CGRectMake(widthContent - sizeStoreImage - edgeSpace, heightScrViewContentSize, sizeStoreImage, sizeStoreImage)];
    NSString* stringURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=20&size=400x400",[sLModel valueForKey:@"latitude"],[sLModel valueForKey:@"longtitude"]];
    stringURL  = [NSString stringWithFormat:@"%@%@",stringURL,@"&markers=size:large%7Ccolor:red%7Clabel:S%7C"];
    stringURL = [NSString stringWithFormat:@"%@%@,%@",stringURL,[sLModel valueForKey:@"latitude"],[sLModel valueForKey:@"longtitude"]];
    [imgStore sd_setImageWithURL:[NSURL URLWithString:stringURL]];
    [scrView addSubview:imgStore];
    
    imgStoreBackground = [[UIImageView alloc]initWithFrame:imgStore.frame];
    [imgStoreBackground setImage:[UIImage imageNamed:@"storelocator_Bg_icon_store"]];
    [scrView addSubview:imgStoreBackground];
    
    CGRect frame = [imgStore frame];
    frame.origin.y += 80;
    frame.size.height = 40;
    btnDirection = [[UIButton alloc]initWithFrame:frame];
    [btnDirection setImage:[UIImage imageNamed:@"storelocator_bt_get"] forState:UIControlStateNormal];
    [btnDirection setImageEdgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
    [btnDirection addTarget:self action:@selector(btnGetDirections_Click:) forControlEvents:UIControlEventTouchUpInside];
    [scrView addSubview:btnDirection];
    
    lblGetdirection = [[UILabel alloc]initWithFrame:CGRectMake(25, 20, sizeStoreImage - 25, 20)];
    [lblGetdirection setFont:[UIFont fontWithName:THEME_FONT_NAME size:10]];
    [lblGetdirection setTextColor:[UIColor blueColor]];
    lblGetdirection.text = SCLocalizedString(@"Get Directions");
    [btnDirection addSubview:lblGetdirection];
}

- (void)initStoreAddress
{
    imgIconAddress = [[UIImageView alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, sizeIcon, sizeIcon)];
    [imgIconAddress setImage:[UIImage imageNamed:@"storelocator_8"]];
    [scrView addSubview:imgIconAddress];
    
    lblStoreAddress = [[UILabel alloc]initWithFrame:CGRectMake(edgeSpace + sizeIcon*3/2, heightScrViewContentSize, widthContent - sizeStoreImage - edgeSpace*2 - sizeIcon*3/2, heightLabel)];
    [lblStoreAddress setLineBreakMode:NSLineBreakByWordWrapping];
    [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    NSString *stringAddress = @"";
    if ([sLModel valueForKey:@"address"]) {
        stringAddress = [NSString stringWithFormat:@"%@",[sLModel valueForKey:@"address"]];
    }
    if ([sLModel valueForKey:@"city"]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@",stringAddress, [sLModel valueForKey:@"city"]];
    }
    if ([sLModel valueForKey:@"state"]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [sLModel valueForKey:@"state"]];
    }
    if ([sLModel valueForKey:@"zipcode"]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [sLModel valueForKey:@"zipcode"]];
    }
    if ([sLModel valueForKey:@"country_name"]) {
        stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [sLModel valueForKey:@"country_name"]];
    }
    [lblStoreAddress setText:stringAddress];
    [lblStoreAddress resizeToFit];
    heightScrViewContentSize += CGRectGetHeight(lblStoreAddress.frame) + space;
    [scrView addSubview:lblStoreAddress];
}
- (void)initStorePhone
{
    if (!([[sLModel valueForKey:@"phone"] isEqualToString:@""] || [sLModel valueForKey:@"phone"] == nil || [[sLModel valueForKey:@"phone"] isKindOfClass:[NSNull class]])) {
        btnStorePhone = [[UIButton alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace - sizeStoreImage, heightButton)];
        [btnStorePhone setBackgroundColor:[UIColor clearColor]];
        [btnStorePhone addTarget:self action:@selector(btnStorePhone_Click:) forControlEvents:UIControlEventTouchUpInside];
        [scrView addSubview:btnStorePhone];
        
        lblStorePhone = [[UILabel alloc]initWithFrame:CGRectMake(sizeIcon +10, 5, CGRectGetWidth(btnStorePhone.frame) - sizeIcon - 10, heightLabel)];
        lblStorePhone.text = [sLModel valueForKey:@"phone"];
        [lblStorePhone setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        lblStorePhone.textColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#009edb"];
        [btnStorePhone addSubview:lblStorePhone];
        
        imgIconPhone = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
        [imgIconPhone setImage:[UIImage imageNamed:@"storelocator_7"]];
        [btnStorePhone addSubview:imgIconPhone];
        
        heightScrViewContentSize += heightButton + space;
    }
}

- (void)initStoreEmail
{
    if (!([[sLModel valueForKey:@"email"] isEqualToString:@""] || [sLModel valueForKey:@"email"] == nil || [[sLModel valueForKey:@"email"] isKindOfClass:[NSNull class]])) {
        _btnStoreEmail = [[UIButton alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, heightButton)];
        [_btnStoreEmail setBackgroundColor:[UIColor clearColor]];
        [_btnStoreEmail addTarget:self action:@selector(btnStoreEmail_Click:) forControlEvents:UIControlEventTouchUpInside];
        [scrView addSubview:_btnStoreEmail];
        
        lblStoreEmail = [[UILabel alloc]initWithFrame:CGRectMake(sizeIcon +10, 5, CGRectGetWidth(_btnStoreEmail.frame) - sizeIcon - 10, heightLabel)];
        lblStoreEmail.text = [sLModel valueForKey:@"email"];
        [lblStoreEmail setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        lblStoreEmail.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#009edb"];
        [_btnStoreEmail addSubview:lblStoreEmail];
        
        _imgIconEmail = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
        [_imgIconEmail setImage:[UIImage imageNamed:@"storelocator_6"]];
        [_btnStoreEmail addSubview:_imgIconEmail];
        
        heightScrViewContentSize += heightButton + space;
    }
    if (heightScrViewContentSize < (CGRectGetHeight(btnDirection.frame) + btnDirection.frame.origin.y)) {
        heightScrViewContentSize = CGRectGetHeight(btnDirection.frame) + btnDirection.frame.origin.y + space;
    }
}

- (void)initStoreWebsite
{
    if (!([[sLModel valueForKey:@"link"] isEqualToString:@""]|| [sLModel valueForKey:@"link"] == nil || [[sLModel valueForKey:@"link"] isKindOfClass:[NSNull class]]))
    {
        _btnStoreWebsite = [[UIButton alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, heightButton)];
        [_btnStoreWebsite setBackgroundColor:[UIColor clearColor]];
        [_btnStoreWebsite addTarget:self action:@selector(btnStoreWebSite_Click:) forControlEvents:UIControlEventTouchUpInside];
        [scrView addSubview:_btnStoreWebsite];
        
        
        lblStoreWebSite = [[UILabel alloc]initWithFrame:CGRectMake(sizeIcon +10, 5, CGRectGetWidth(_btnStoreWebsite.frame) - sizeIcon - 10, heightLabel)];
        lblStoreWebSite.text = [sLModel valueForKey:@"link"];
        [lblStoreWebSite setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        lblStoreWebSite.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#009edb"];
        [_btnStoreWebsite addSubview:lblStoreWebSite];
        
        _imgIconWebsite = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
        [_imgIconWebsite setImage:[UIImage imageNamed:@"storelocator_5"]];
        [_btnStoreWebsite addSubview:_imgIconWebsite];
        
        heightScrViewContentSize += heightButton + space;
    }
}

- (void)initStoreInformation
{
    if (!([[sLModel valueForKey:@"description"] isEqualToString:@""]||[sLModel valueForKey:@"description"] == nil || [[sLModel valueForKey:@"description"] isKindOfClass:[NSNull class]])) {
        viewInfomation = [[UIView alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, heightButton * 2)];
        [viewInfomation setBackgroundColor:[UIColor clearColor]];
        [scrView addSubview:viewInfomation];
        
        _imgInformation = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
        [_imgInformation setImage:[UIImage imageNamed:@"storelocator_1"]];
        [viewInfomation addSubview:_imgInformation];
        
        lblInfomationContents = [[UILabel alloc]initWithFrame:CGRectMake(sizeIcon +10, 5, CGRectGetWidth(viewInfomation.frame) - sizeIcon - 10, heightLabel*2)];
        [lblInfomationContents setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        [lblInfomationContents setText:[self flattenHTML:[sLModel valueForKey:@"description"]]];
        [lblInfomationContents setLineBreakMode:NSLineBreakByWordWrapping];
        [viewInfomation addSubview:lblInfomationContents];
        NSLog(@"%f",lblInfomationContents.expectedHeight);
        if (lblInfomationContents.expectedHeight > (heightLabel*2)) {
            btnShowMoreLess = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(viewInfomation.frame) - 100, heightLabel*2, 100, 20)];
            [btnShowMoreLess addTarget:self action:@selector(btnShowMoreLess_Click:) forControlEvents:UIControlEventTouchUpInside];
            [btnShowMoreLess setTitle:SCLocalizedString(@"Show more") forState:UIControlStateNormal];
            [btnShowMoreLess.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            isShowMore = YES;
            [btnShowMoreLess setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            heightLableInformationRaise = lblInfomationContents.expectedHeight - heightLabel*2;
            [viewInfomation addSubview:btnShowMoreLess];
        }else
        {
            [lblInfomationContents resizeToFit];
        }
        heightScrViewContentSize += heightButton * 2  + space;
    }
}

- (void)initStoreOpenHour
{
    viewOpenHours = [[UIView alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, 170)];
    [viewOpenHours setBackgroundColor:[UIColor clearColor]];
    [scrView addSubview:viewOpenHours];
    
    _imgIconOpenHours = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
    [_imgIconOpenHours setImage:[UIImage imageNamed:@"storelocator_4"]];
    [viewOpenHours addSubview:_imgIconOpenHours];
    
    labelTitleX = sizeIcon + 10;
    widthTitle = 100;
    labelValueX = labelTitleX + widthTitle +10;
    widthValue = 150;
    heightOpenHourView = 5;
    NSString *openHours = @"Open Hours";
    lblOpenHours = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, 0, CGRectGetWidth(viewOpenHours.frame) - sizeIcon - 10, heightButton)];
    [lblOpenHours setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE + 3]];
    [lblOpenHours setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#4d535e"]];
    [lblOpenHours setText:SCLocalizedString(@"Opening Hours")];
    [viewOpenHours addSubview:lblOpenHours];
    lblOpenHours.simiObjectIdentifier = openHours;
    heightOpenHourView += heightButton;
    
    
    lblMonday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblMonday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Monday")]];
    [viewOpenHours addSubview:lblMonday];
    
    lblMondayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"monday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"monday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"monday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"monday_close"] isEqualToString:@""] || [[sLModel valueForKey:@"monday_close"] isEqualToString:@"00:00"]) {
            lblMondayContent.text = SCLocalizedString(@"Open");
        }else
        {
            lblMondayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"monday_open"],[sLModel valueForKey:@"monday_close"]];
        }
    }else
    {
        lblMondayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblMondayContent];
    heightOpenHourView += heightLabel;
    
    lblTuesday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblTuesday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Tuesday")]];
    [viewOpenHours addSubview:lblTuesday];
    
    lblTuesdayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"tuesday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"tuesday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"tuesday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"tuesday_close"] isEqualToString:@""]||[[sLModel valueForKey:@"tuesday_close"] isEqualToString:@"00:00"]) {
            lblTuesdayContent.text = SCLocalizedString(@"Open");
        }else
        {
            lblTuesdayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"tuesday_open"],[sLModel valueForKey:@"tuesday_close"]];
        }
    }else
    {
        lblTuesdayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblTuesdayContent];
    heightOpenHourView +=  heightLabel;
    
    lblWednesday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblWednesday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Wednesday")]];
    [viewOpenHours addSubview:lblWednesday];
    
    lblWednesdayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"wednesday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"wednesday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"wednesday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"wednesday_close"] isEqualToString:@""]||[[sLModel valueForKey:@"wednesday_close"] isEqualToString:@"00:00"]) {
            lblWednesdayContent.text = SCLocalizedString(@"Open");
            
        }else
        {
            lblWednesdayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"wednesday_open"],[sLModel valueForKey:@"wednesday_close"]];
        }
    }else
    {
        lblWednesdayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblWednesdayContent];
    heightOpenHourView +=  heightLabel;
    
    lblThursday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblThursday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Thursday")]];
    [viewOpenHours addSubview:lblThursday];
    
    lblThursdayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"thursday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"thursday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"thursday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"thursday_close"] isEqualToString:@""]||[[sLModel valueForKey:@"thursday_close"] isEqualToString:@"00:00"]) {
            lblThursdayContent.text = SCLocalizedString(@"Open");
        }else
        {
            lblThursdayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"thursday_open"],[sLModel valueForKey:@"thursday_close"]];
        }
    }else
    {
        lblThursdayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblThursdayContent];
    heightOpenHourView +=  heightLabel;
    
    lblFriday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblFriday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Friday")]];
    [viewOpenHours addSubview:lblFriday];
    
    lblFridayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"friday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"friday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"friday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"friday_close"] isEqualToString:@""]||[[sLModel valueForKey:@"friday_close"] isEqualToString:@"00:00"]) {
            lblFridayContent.text = SCLocalizedString(@"Open");
        }else
        {
            lblFridayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"friday_open"],[sLModel valueForKey:@"friday_close"]];
        }
    }else
    {
        lblFridayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblFridayContent];
    heightOpenHourView +=  heightLabel;
    
    lblSaturday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblSaturday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Saturday")]];
    [viewOpenHours addSubview:lblSaturday];
    
    lblSaturdayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"saturday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"saturday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"saturday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"saturday_close"] isEqualToString:@""]||[[sLModel valueForKey:@"saturday_close"] isEqualToString:@"00:00"]) {
            lblSaturdayContent.text = SCLocalizedString(@"Open");
        }else
        {
            lblSaturdayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"saturday_open"],[sLModel valueForKey:@"saturday_close"]];
        }
    }else
    {
        lblSaturdayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblSaturdayContent];
    heightOpenHourView +=  heightLabel;
    
    lblSunday = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightOpenHourView, widthTitle, heightLabel)];
    [lblSunday setText:[NSString stringWithFormat:@"%@:", SCLocalizedString(@"Sunday")]];
    [viewOpenHours addSubview:lblSunday];
    
    lblSundayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelValueX, heightOpenHourView, widthValue, heightLabel)];
    if ([[sLModel valueForKey:@"sunday_status"] isEqualToString:@"1"]) {
        if ([[sLModel valueForKey:@"sunday_open"] isEqualToString:@""]||[[sLModel valueForKey:@"sunday_open"] isEqualToString:@"00:00"]||[[sLModel valueForKey:@"sunday_close"] isEqualToString:@""]||[[sLModel valueForKey:@"sunday_close"] isEqualToString:@"00:00"]) {
            lblSundayContent.text = SCLocalizedString(@"Open");
        }else
        {
            lblSundayContent.text = [NSString stringWithFormat:@"%@ - %@",[sLModel valueForKey:@"sunday_open"],[sLModel valueForKey:@"sunday_close"]];
        }
    }else
    {
        lblSundayContent.text = SCLocalizedString(@"Close");
    }
    [viewOpenHours addSubview:lblSundayContent];
    heightOpenHourView +=  heightLabel;
    
    for (UIView *view in viewOpenHours.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            if (![(NSString*)label.simiObjectIdentifier isEqualToString:openHours] ) {
                [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
                [label setTextColor: [[SimiGlobalVar sharedInstance] colorWithHexString:@"#4d535e"]];
            }
        }
    }
    heightScrViewContentSize += CGRectGetHeight(viewOpenHours.frame) + space;
}

-(void)initStoreSpecialDays
{
    NSMutableArray *arraySpecialDays = (NSMutableArray*)[sLModel valueForKey:@"special_days"];
    if (arraySpecialDays.count > 0) {
        haveSpecialsDay = YES;
        viewSpecialsDay = [[UIView alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, heightButton)];
        [viewSpecialsDay setBackgroundColor:[UIColor clearColor]];
        [scrView addSubview:viewSpecialsDay];
        
        _imgIconSpecialDay = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
        [_imgIconSpecialDay setImage:[UIImage imageNamed:@"storelocator_3"]];
        [viewSpecialsDay addSubview:_imgIconSpecialDay];
        
        lblSpecialsDay = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, 0, CGRectGetWidth(viewSpecialsDay.frame) - labelTitleX, heightButton)];
        lblSpecialsDay.text = SCLocalizedString(@"Specials Day");
        [lblSpecialsDay setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE + 3]];
        [lblSpecialsDay setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#4d535e"]];
        [viewSpecialsDay addSubview:lblSpecialsDay];
        
        NSString *stringSpecialDaysContent = @"";
        for (int i = 0; i < arraySpecialDays.count; i++) {
            NSDictionary *dict = (NSDictionary*)[arraySpecialDays objectAtIndex:i];
            stringSpecialDaysContent = [NSString stringWithFormat:@"%@%@, %@ - %@\n",stringSpecialDaysContent,[dict valueForKey:@"date"],[dict valueForKey:@"time_open"],[dict valueForKey:@"time_close"]];
        }
        lblSpecialsDayContent = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightButton, widthContent - labelTitleX, heightLabel)];
        lblSpecialsDayContent.text = stringSpecialDaysContent;
        [lblSpecialsDayContent setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]];
        lblSpecialsDayContent.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#4d535e"];
        [viewSpecialsDay addSubview:lblSpecialsDayContent];
        
        float heightViewSpecialDays = [lblSpecialsDayContent resizeToFit];
        [viewSpecialsDay setFrame:CGRectMake(edgeSpace, heightScrViewContentSize, CGRectGetWidth(viewSpecialsDay.frame), heightViewSpecialDays)];
        
        heightScrViewContentSize += heightViewSpecialDays;
    }
}

-(void)initStoreHolidays
{
#pragma mark Holidays
    NSMutableArray *arrayHolidays = [sLModel valueForKeyPath:@"holiday_days"];
    if (arrayHolidays.count > 0) {
        haveHolidays = YES;
        viewHolidays = [[UIView alloc]initWithFrame:CGRectMake(edgeSpace, heightScrViewContentSize, widthContent - 2*edgeSpace, heightButton)];
        [viewHolidays setBackgroundColor:[UIColor clearColor]];
        [scrView addSubview:viewHolidays];
        
        _imgIconHolidays = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, sizeIcon, sizeIcon)];
        [_imgIconHolidays setImage:[UIImage imageNamed:@"storelocator_2"]];
        [viewHolidays addSubview:_imgIconHolidays];
        
        lblHolidays = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, 0, CGRectGetWidth(viewHolidays.frame) - labelTitleX, heightButton)];
        lblHolidays.text = SCLocalizedString(@"Holidays");
        [lblHolidays setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE + 3]];
        [lblHolidays setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#4d535e"]];
        [viewHolidays addSubview:lblHolidays];
        
        NSString *stringHolidaysContent = @"";
        for (int i = 0; i < arrayHolidays.count; i++) {
            NSDictionary *dict2 = (NSDictionary*)[arrayHolidays objectAtIndex:i];
            stringHolidaysContent = [NSString stringWithFormat:@"%@%@\n",stringHolidaysContent,[dict2 valueForKey:@"date"]];
        }
        lblHolidaysContent = [[UILabel alloc]initWithFrame:CGRectMake(labelTitleX, heightButton, widthContent - labelTitleX, heightLabel)];
        lblHolidaysContent.text = stringHolidaysContent;
        [lblHolidaysContent setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 3]];
        [lblHolidaysContent setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#4d535e"]];
        [viewHolidays addSubview:lblHolidaysContent];
        
        float heightViewHolidays = [lblHolidaysContent resizeToFit];
        [viewHolidays setFrame:CGRectMake(edgeSpace, heightScrViewContentSize, CGRectGetWidth(viewHolidays.frame), heightViewHolidays)];
        
        heightScrViewContentSize += heightViewHolidays;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [scrView setFrame:CGRectMake(0, 0, 680, 512)];
    }else
    {
        [scrView setFrame:self.view.bounds];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Action
- (void)btnStorePhone_Click:(id)sender
{
    NSString *phNo = [NSString  stringWithFormat:@"telprompt:%@",[sLModel valueForKey:@"phone"]];
    NSURL *phoneUrl = [[NSURL alloc]initWithString:[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:SCLocalizedString(@"Call facility is not available!!!") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [calert show];
    }
}
- (void)btnStoreEmail_Click:(id)sender
{
    NSString *email = [sLModel valueForKeyPath:@"email"];
    NSString *emailContent = SCLocalizedString(@"Content");
    [self sendEmailToStoreWithEmail:email andEmailContent:emailContent];
}
- (void)btnStoreWebSite_Click:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://",[sLModel valueForKey:@"link"]]]];
}
- (void)btnShowMoreLess_Click:(id)sender
{
    if(isShowMore)
    {
        isShowMore = NO;
        [btnShowMoreLess setTitle:SCLocalizedString(@"Show less") forState:UIControlStateNormal];
        [lblInfomationContents resizeToFit];
        
        CGRect frame = btnShowMoreLess.frame;
        frame.origin.y += heightLableInformationRaise;
        [btnShowMoreLess setFrame:frame];
        
        frame = viewInfomation.frame;
        frame.size.height += heightLableInformationRaise;
        [viewInfomation setFrame:frame];
        
        frame = viewOpenHours.frame;
        frame.origin.y += heightLableInformationRaise;
        [viewOpenHours setFrame:frame];
        if (haveSpecialsDay) {
            frame = viewSpecialsDay.frame;
            frame.origin.y += heightLableInformationRaise;
            [viewSpecialsDay setFrame:frame];
        }
        
        if (haveHolidays) {
            frame = viewHolidays.frame;
            frame.origin.y += heightLableInformationRaise;
            [viewHolidays setFrame:frame];
        }
        [scrView setContentSize:CGSizeMake(SIZE_SCROLL_VIEW_DETAIL, heightScrViewContentSize + heightLableInformationRaise)];
    }else
    {
        isShowMore = YES;
        [btnShowMoreLess setTitle: SCLocalizedString(@"Show more") forState:UIControlStateNormal];
        
        CGRect frame = lblInfomationContents.frame;
        frame.size.height -= heightLableInformationRaise;
        [lblInfomationContents setFrame:frame];
        
        frame = viewInfomation.frame;
        frame.size.height -= heightLableInformationRaise;
        [viewInfomation setFrame:frame];
        
        frame = btnShowMoreLess.frame;
        frame.origin.y -= heightLableInformationRaise;
        [btnShowMoreLess setFrame:frame];
        
        frame = viewOpenHours.frame;
        frame.origin.y -= heightLableInformationRaise;
        [viewOpenHours setFrame:frame];
        if (haveSpecialsDay) {
            frame = viewSpecialsDay.frame;
            frame.origin.y -= heightLableInformationRaise;
            [viewSpecialsDay setFrame:frame];
        }
        
        if (haveHolidays) {
            frame = viewHolidays.frame;
            frame.origin.y -= heightLableInformationRaise;
            [viewHolidays setFrame:frame];
        }
        
        [scrView setContentSize:CGSizeMake(SIZE_SCROLL_VIEW_DETAIL, heightScrViewContentSize)];
    }
}

- (void)btnViewMap_Click:(id)sender
{
    [self.delegate returnMapViewController:self.sLModel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnGetDirections_Click:(id)sender
{
    // Sua lai dia chi den sau
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString: [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%@,%@&center=%f,%f&zoom=14&views=traffic",currentLatitude , currentLongitude,[sLModel valueForKey:@"latitude"],[sLModel valueForKey:@"longtitude"],currentLatitude, currentLongitude]]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"To find the way to the store, you must install Google Mapp App first.l" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
#pragma mark Email Delegate
- (void)sendEmailToStoreWithEmail:(NSString *)email andEmailContent:(NSString *)emailContent
{
    if([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
		[controller setToRecipients:[[NSArray alloc] initWithObjects:email, nil]];
		
		[controller setSubject:[NSString stringWithFormat:@""]];
		[controller setMessageBody:emailContent isHTML:NO];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
            [self presentViewController:controller animated:YES completion:NULL];
		}
		else {
            [self presentViewController:controller animated:YES completion:NULL];
		}
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"No Email Account") message:SCLocalizedString(@"Open Settings app to set up an email account")
													   delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
		
		[alert show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	if(result==MFMailComposeResultCancelled)
	{
        [controller dismissViewControllerAnimated:YES completion:NULL];
	}
	if(result==MFMailComposeResultSent)
	{  UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Your Email was sent succesfully.") message:nil delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
		[sent show];
		[controller dismissViewControllerAnimated:YES completion:NULL];
	}
	if(result==MFMailComposeResultFailed)
	{UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Failed") message:SCLocalizedString(@"Your mail was not sent") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
		[sent show];
		
		[controller dismissViewControllerAnimated:YES completion:NULL];
		
	}
}
#pragma mark Convert HTML to String
- (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}
@end
