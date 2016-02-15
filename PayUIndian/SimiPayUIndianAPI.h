//
//  SimiPayUIndianAPI.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 2/2/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiGlobalVar+PayUIndian.h"

@interface SimiPayUIndianAPI : SimiAPI
-(void)getPaymentHashWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;
-(void)updatePayUIndianPaymentWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
