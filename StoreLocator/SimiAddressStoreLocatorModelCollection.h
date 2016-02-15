//
//  SimiAddressStoreLocatorModelCollection.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiModelCollection.h>
@interface SimiAddressStoreLocatorModelCollection : SimiModelCollection
- (void)getCountryListWithParams:(NSDictionary*)dict;
@end
