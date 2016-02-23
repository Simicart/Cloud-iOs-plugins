//
//  SimiCheckOutAPI.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/26/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiCheckOutAPI : SimiAPI
-(void)getPublishKeyWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;
-(void)createCheckOutPaymentWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
