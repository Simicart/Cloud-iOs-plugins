//
//  SimiTagModelCollection.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiTagModelCollection : SimiModelCollection
- (void)getTagWithOffset:(NSString*)offset limit:(NSString*)limit;
@end
