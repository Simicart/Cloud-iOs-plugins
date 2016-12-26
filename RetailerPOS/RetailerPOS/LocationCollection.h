//
//  LocationCollection.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 4/21/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "CollectionAbstract.h"
#import "Location.h"

@interface LocationCollection : CollectionAbstract

+ (LocationCollection *)allLocation;

- (Location *)getLocationById:(NSString *)locId;

@end
