//
//  SCStoreListTableViewCell.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCStoreListTableViewCell.h"
#import <SimiCartBundle/UIImageView+WebCache.h>

@implementation SCStoreListTableViewCell
{
    float cellWidth;
    float imageSize;
    float imagePaddingLeft;
    float imagePaddingTop;
    float labelPaddingLeft;
    float labelHeight;
    float labelPaddingRight;
    float labelWidth;
    float labelDistanceWidth;
}
@synthesize lblStoreAddress, lblStoreDistance, lblStoreName, lblCall, lblMail, lblMap, btnMap;
@synthesize imgStoreImage, btnCall, btnMail, delegate, storeLocatorModel, imgBackground;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andStoreData:(SimiStoreLocatorModel*)storeLocatorModel_;
{
    cellWidth = SCREEN_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellWidth = 320;
    }
    imageSize = 70;
    imagePaddingLeft = 5;
    imagePaddingTop = 15;
    labelPaddingLeft = imageSize + imagePaddingLeft + 10;;
    labelPaddingRight = 15;
    labelHeight = 20;
    labelWidth = cellWidth - labelPaddingLeft - labelPaddingRight;
    labelDistanceWidth = 85;
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.storeLocatorModel = storeLocatorModel_;
        
        lblStoreName = [[UILabel alloc]initWithFrame:CGRectMake(labelPaddingLeft , 5, labelWidth - labelDistanceWidth, labelHeight)];
        [lblStoreName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
        [lblStoreName setText:[storeLocatorModel valueForKey:@"name"]];
        [lblStoreName setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"]];
        [self addSubview:lblStoreName];
        
        lblStoreAddress = [[UILabel alloc]initWithFrame:CGRectMake(labelPaddingLeft, 30, labelWidth, 35)];
        [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [lblStoreAddress setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"]];
        NSString *stringAddress = @"";
        if ([storeLocatorModel valueForKey:@"address"]) {
            stringAddress = [NSString stringWithFormat:@"%@",[storeLocatorModel valueForKey:@"address"]];
        }
        if ([storeLocatorModel valueForKey:@"city"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@",stringAddress, [storeLocatorModel valueForKey:@"city"]];
        }
        if ([storeLocatorModel valueForKey:@"state"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [storeLocatorModel valueForKey:@"state"]];
        }
        if ([storeLocatorModel valueForKey:@"zipcode"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [storeLocatorModel valueForKey:@"zipcode"]];
        }
        if ([storeLocatorModel valueForKey:@"country_name"]) {
            stringAddress = [NSString stringWithFormat:@"%@, %@", stringAddress, [storeLocatorModel valueForKey:@"country_name"]];
        }
        [lblStoreAddress setText:stringAddress];
        [lblStoreAddress resizeToFit];
        [self addSubview:lblStoreAddress];
        
        lblStoreDistance = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - labelDistanceWidth, 5, labelDistanceWidth, labelHeight)];
        [lblStoreDistance setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"]];
        [lblStoreDistance setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        float distance = [[NSString stringWithFormat:@"%@",[storeLocatorModel valueForKey:@"distance"]]floatValue]/1000;
        NSString *stringlblStoreDistance = [NSString stringWithFormat:@"%0.2f %@",distance, SCLocalizedString(@"km")];
        [lblStoreDistance setText:stringlblStoreDistance];
        [self addSubview:lblStoreDistance];
        
        imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(imagePaddingLeft, imagePaddingTop, imageSize, imageSize)];
        [imgBackground setImage:[UIImage imageNamed:@"storelocator_Bg_icon_store.png"]];
        
        imgStoreImage = [[UIImageView alloc]initWithFrame:imgBackground.frame];
        [imgStoreImage setContentMode:UIViewContentModeScaleAspectFit];
        if (![[storeLocatorModel valueForKey:@"image"] isEqualToString:@""]) {
            [imgStoreImage sd_setImageWithURL:[storeLocatorModel valueForKey:@"image"] placeholderImage:[UIImage imageNamed:@"storelocator_icon_store"]];
            [self addSubview:imgStoreImage];
            [self addSubview:imgBackground];
        }else
        {
            [imgStoreImage setImage:[UIImage imageNamed:@"storelocator_icon_store"]];
            [self addSubview:imgStoreImage];
        }
        
        btnCall = [UIButton new];
        [btnCall setImage:[UIImage imageNamed:@"storelocator_ic_call_iphone"] forState:UIControlStateNormal];
        [btnCall setImageEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        [btnCall addTarget:self action:@selector(btnCall_Click:) forControlEvents:UIControlEventTouchUpInside];
        lblCall = [UILabel new];
        [lblCall setText:SCLocalizedString(@"Call")];
        [lblCall setTextColor:[UIColor blackColor]];
        [lblCall setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [lblCall setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [btnCall setFrame:CGRectMake(84, 60, 70, 34)];
            [lblCall setFrame:CGRectMake(35, 13, 35, 21)];
            [btnCall addSubview:lblCall];
            [self addSubview:btnCall];
            if (![storeLocatorModel valueForKey:@"phone"]) {
                [btnCall setEnabled:NO];
            }
        }
        
        btnMail = [UIButton new];
        [btnMail setImage:[UIImage imageNamed:@"storelocator_ic_mail_iphone"] forState:UIControlStateNormal];
        [btnMail setImageEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        [btnMail addTarget:self action:@selector(btnMail_Click:) forControlEvents:UIControlEventTouchUpInside];
        lblMail = [UILabel new];
        [lblMail setText:SCLocalizedString(@"Email")];
        [lblMail setTextColor:[UIColor blackColor]];
        [lblMail setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [lblMail setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [btnMail setFrame:CGRectMake(159, 60, 70, 34)];
            [lblMail setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMail addSubview:lblMail];
            [self addSubview:btnMail];
            if (![storeLocatorModel valueForKey:@"email"]) {
                [btnMail setEnabled:NO];
            }
        }else
        {
            [btnMail setFrame:CGRectMake(85, 75, 70, 34)];
            [lblMail setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMail addSubview:lblMail];
            [self addSubview:btnMail];
            if (![storeLocatorModel valueForKey:@"email"]) {
                [btnMail setEnabled:NO];
            }
        }
        
        btnMap = [UIButton new];
        [btnMap setImage:[UIImage imageNamed:@"storelocator_ic_map_iphone"] forState:UIControlStateNormal];
        [btnMap setImageEdgeInsets:UIEdgeInsetsMake(13, 0, 0, 0)];
        [btnMap addTarget:self action:@selector(btnMap_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        lblMap = [UILabel new];
        [lblMap setText:SCLocalizedString(@"Map")];
        [lblMap setTextColor:[UIColor blackColor]];
        [lblMap setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [lblMap setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [btnMap setFrame:CGRectMake(237, 60, 70, 34)];
            [lblMap setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMap addSubview:lblMap];
            [self addSubview:btnMap];
        }else
        {
            [btnMap setFrame:CGRectMake(185, 75, 70, 34)];
            [lblMap setFrame:CGRectMake(35, 13, 35, 21)];
            [btnMap addSubview:lblMap];
            [self addSubview:btnMap];
        }
    }
    return self;
}

/*
- (void)initStoreListCell
{
    lblStoreName.text = SCLocalizedString([storeLocatorModel valueForKey:@"name"]);
    [lblStoreName setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:THEME_FONT_SIZE]];
    lblStoreName.textColor = [self colorWithStringHex:@"393939"];
    
    
    NSString* stringlblStoreAddress = [NSString stringWithFormat:@"%@, %@, %@",[storeLocatorModel valueForKey:@"address"], [storeLocatorModel valueForKey:@"city"],[storeLocatorModel valueForKey:@"country"]];
    lblStoreAddress.text = SCLocalizedString(stringlblStoreAddress);
    [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    lblStoreAddress.textColor = [self colorWithStringHex:@"393939"];
    
    
    float distance = [[NSString stringWithFormat:@"%@",[storeLocatorModel valueForKey:@"distance"]]floatValue]/1000;
    NSString *stringlblStoreDistance = [NSString stringWithFormat:@"%0.2f %@",distance, SCLocalizedString(@"km")];
    lblStoreDistance.text = SCLocalizedString(stringlblStoreDistance);
    [lblStoreDistance setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
    lblStoreDistance.textColor = [self colorWithStringHex:@"393939"];
    if (![[storeLocatorModel valueForKey:@"image"] isEqualToString:@""]) {
        [imgStoreImage sd_setImageWithURL:[storeLocatorModel valueForKey:@"image"]];
    }else
    {
        [imgStoreImage setImage:[UIImage imageNamed:@"storelocator_icon_store.png"]];
        [imgBackground removeFromSuperview];
    }
    
    
    if ([storeLocatorModel valueForKey:@"phone"] == nil) {
        [btnCall setEnabled:NO];
    }
    
    if ([storeLocatorModel valueForKey:@"email"] == nil) {
        [btnMail setEnabled:NO];
    }
}
*/
- (void)btnCall_Click:(id)sender
{
    NSString *phNo = [NSString  stringWithFormat:@"telprompt:%@",[storeLocatorModel valueForKey:@"phone"]];
    NSURL *phoneUrl = [[NSURL alloc]initWithString:[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Alert") message:SCLocalizedString(@"Call facility is not available.") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [calert show];
    }
}
- (void)btnMail_Click:(id)sender
{
    NSString *email = [storeLocatorModel valueForKeyPath:@"email"];
    NSString *emailContent = @"Content";
    [self.delegate sendEmailToStoreWithEmail:email andEmailContent:emailContent];
}
- (void)btnMap_Click:(id)sender
{
    [self.delegate choiceStoreLocatorWithStoreLocatorModel:self.storeLocatorModel];
}

#pragma mark Modify UIColor

- (UIColor*) colorWithStringHex:(NSString*)stringHex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:stringHex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
