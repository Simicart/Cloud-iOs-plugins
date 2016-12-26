//
//  LocationCollection.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 4/21/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "LocationCollection.h"
#import "Configuration.h"

@implementation LocationCollection

+ (LocationCollection *)allLocation
{
    return (LocationCollection *)[Configuration getSingleton:@"LocationCollection"];
}

- (id)init
{
    if (self = [super init]) {
        self.modelClass = @"Location";
    }
    return self;
}

- (Location *)getLocationById:(NSString *)locId
{
    __block Location *location;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[obj getId] integerValue] == [locId integerValue]) {
            location = obj;
            *stop = YES;
        }
    }];
    return location;
}

@end
