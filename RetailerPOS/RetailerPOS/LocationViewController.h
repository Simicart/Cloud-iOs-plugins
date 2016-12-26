//
//  LocationViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 4/21/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaffInfoViewController.h"

@class StaffInfoViewController;

@interface LocationViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *formData;
@property (strong, nonatomic) StaffInfoViewController *infoViewController;

@end
