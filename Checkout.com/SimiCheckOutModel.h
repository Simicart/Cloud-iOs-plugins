//
//  SimiCheckOutModel.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiCheckOutModel : SimiModel
-(void)getPublishKey:(NSDictionary *)params;
-(void)createCheckOutPaymentWithParam:(NSDictionary *)params;
@end
