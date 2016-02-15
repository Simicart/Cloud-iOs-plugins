//
//  SimiStoreLocatorAPI.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiAPI.h>
@interface SimiStoreLocatorAPI : SimiAPI
- (void)getStoreListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
