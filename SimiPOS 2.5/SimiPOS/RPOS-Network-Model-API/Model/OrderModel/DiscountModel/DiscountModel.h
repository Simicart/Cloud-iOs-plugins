//
//  DiscountModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "RetailerPosModel.h"

@interface DiscountModel : RetailerPosModel

/*
 Notification name: DidSetDisCount
 */
- (void)setDiscountWithData:(NSDictionary *)params;


@end
