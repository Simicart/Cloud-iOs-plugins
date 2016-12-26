//
//  StaffInfoViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/25/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserCollection.h"

@class StaffListViewController;
@interface StaffInfoViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) UserCollection *userList;
@property (strong, nonatomic) StaffListViewController *listController;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

- (void)cancelCreate;

- (void)saveUser;

- (void)deleteUser;

@end
