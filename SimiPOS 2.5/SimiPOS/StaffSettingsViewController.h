//
//  StaffSettingsViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/2/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCollection.h"

@interface StaffSettingsViewController : UITableViewController

@property (strong, nonatomic) UserCollection *userList;
- (void)loadUsers;

- (void)addNewStaffUser;

@end
