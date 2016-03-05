//
//  SimiIpayAPI.h
//  SimiCartPluginFW
//
//  Created by Lionel on 3/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiIpayAPI : SimiAPI
- (void)getConfigWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)updateIpayOrderWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
