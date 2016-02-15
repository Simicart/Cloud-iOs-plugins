//
//  SimiCLController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiCLController.h"

@implementation SimiCLController
@synthesize locationManager, delegate;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
    [self.delegate locationError:error];
}

@end
