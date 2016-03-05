//
//  SimiIpayModel.h
//  SimiCartPluginFW
//
//  Created by Lionel on 3/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiIpayModel : SimiModel
- (void)getConfigWithParams:(NSDictionary *)params;
- (void)updateIpayOrderWithParams:(NSDictionary *)params;
@end
