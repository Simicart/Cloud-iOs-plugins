//
//  SimiStoreLocatorMaker.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "SimiStoreLocatorModel.h"
@interface SimiStoreLocatorMaker : GMSMarker
@property (nonatomic, strong) SimiStoreLocatorModel *storeLocatorModel;
@end
