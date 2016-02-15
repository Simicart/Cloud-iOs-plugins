//
//  SimiTagAPI.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiTagAPI : SimiAPI
- (void)getTagListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
