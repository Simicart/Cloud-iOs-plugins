//
//  SimiCLController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@protocol SimiCLControllerDelegate
@optional
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end
@interface SimiCLController : NSObject<CLLocationManagerDelegate>{
	CLLocationManager *locationManager;
    id delegate;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) id  delegate;

@end
