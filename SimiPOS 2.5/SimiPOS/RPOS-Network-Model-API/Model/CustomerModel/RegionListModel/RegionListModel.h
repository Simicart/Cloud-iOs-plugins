//
//  RegionListModel.h
//  SimiPOS
//
//  Created by Dong on 9/16/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface RegionListModel : RetailerPosModel

- (void)getRegionListWithCountryCode:(NSString*) countryCode;

@end
