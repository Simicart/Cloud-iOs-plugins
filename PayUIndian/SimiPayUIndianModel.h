//
//  SimiPayUIndianModel.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 2/2/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiPayUIndianModel : SimiModel
-(void)getPaymentHash:(NSDictionary *)params;
-(void)updatePayment:(NSDictionary *)params;
@end