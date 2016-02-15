//
//  SimiStoreLocatorCellCountry.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiAddressModel.h>

@interface SimiStoreLocatorCellCountry : UITableViewCell

@property (nonatomic, strong) UILabel *lblCellContent;
@property (nonatomic, strong) SimiAddressModel* simiAddressModel;
@end
