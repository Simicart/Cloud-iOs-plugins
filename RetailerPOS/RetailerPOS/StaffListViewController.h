//
//  StaffListViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/25/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCollection.h"
#import "StaffSettingsViewController.h"

@interface StaffListViewController : UITableViewController

@property (strong, nonatomic) UserCollection *userList;

@end
