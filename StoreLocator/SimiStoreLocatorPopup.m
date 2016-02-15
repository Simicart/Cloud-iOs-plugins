//
//  SimiStoreLocatorPopup.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorPopup.h"
#import "SimiGlobalVar+StoreLocator.h"

@implementation SimiStoreLocatorPopup
@synthesize delegate, lblStoreAddress, lblStoreName, imageStore, storeLocatorModel, imageBackGround;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imagePopup = [[UIImageView alloc]initWithFrame:self.bounds];
        [_imagePopup setImage:[UIImage imageNamed:@"storelocator_popup"]];
        [self addSubview:_imagePopup];
        
        imageStore = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
        [self addSubview:imageStore];
        
        imageBackGround = [[UIImageView alloc] initWithFrame:imageStore.frame];
        [imageBackGround setImage:[UIImage imageNamed:@"storelocator_Bg_icon_store"]];
        [self addSubview:imageBackGround];
        
        _imageIconAddress = [[UIImageView alloc]initWithFrame:CGRectMake(65, 30, 20, 20)];
        [_imageIconAddress setImage:[UIImage imageNamed:@"storelocator_locator"]];
        [self addSubview:_imageIconAddress];
        
        lblStoreName = [UILabel new];
        lblStoreName.textColor = [UIColor redColor];
        [lblStoreName setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",THEME_FONT_NAME,@"Bold"] size:THEME_FONT_SIZE]];
        
        lblStoreAddress = [UILabel new];
        lblStoreAddress.textColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#393939"];
        [lblStoreAddress setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [lblStoreName setFrame:CGRectMake(80, 5, 175, 20)];
            [lblStoreAddress setFrame:CGRectMake(85, 30, 170, 20)];
        }else
        {
            [lblStoreName setFrame:CGRectMake(85, 10, 205, 20)];
            [lblStoreAddress setFrame:CGRectMake(85, 35, 205, 20)];
        }
        [self addSubview:lblStoreName];
        [self addSubview:lblStoreAddress];
    }
    return self;
}

- (void)setContentForPopup
{
    lblStoreName.text = SCLocalizedString([storeLocatorModel valueForKey:@"name"]);
    
    lblStoreAddress.text = [NSString stringWithFormat:@"%@, %@, %@",[storeLocatorModel valueForKey:@"address"],[storeLocatorModel valueForKey:@"city"],[storeLocatorModel valueForKey:@"country"]];
    [lblStoreAddress resizeToFit];
    
    if (lblStoreAddress.frame.size.height > 40 ) {
        CGRect frame = lblStoreAddress.frame;
        frame.size.height = 40;
        [lblStoreAddress setFrame:frame];
    }
    if (![[storeLocatorModel valueForKey:@"image"] isEqualToString:@""]) {
        [imageStore sd_setImageWithURL:[storeLocatorModel valueForKey:@"image"]];
        [self addSubview:imageBackGround];
    }else
    {
        [imageStore setImage:[UIImage imageNamed:@"storelocator_icon_store.png"]];
        [imageBackGround removeFromSuperview];
    }
}
@end
