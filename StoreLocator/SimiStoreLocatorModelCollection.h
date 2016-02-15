//
//  SimiStoreLocatorModelCollection.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiModelCollection.h>
#import "SimiStoreLocatorAPI.h"

@interface SimiStoreLocatorModelCollection : SimiModelCollection
- (void)getStoreListWithLatitude:(NSString*)lat longitude:(NSString*)lng offset:(NSString*)offset limit:(NSString*)limit;
- (void)getStoreListWithLatitude:(NSString *)lat longitude:(NSString *)lng offset:(NSString *)offset limit:(NSString *)limit country:(NSString*)country city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString*)tag;
@end
