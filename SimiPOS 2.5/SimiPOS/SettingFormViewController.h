//
//  SettingFormViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralSettingsViewController.h"

@class SettingSectionsViewController;
@interface SettingFormViewController : GeneralSettingsViewController
@property (strong, nonatomic) SettingSectionsViewController *sections;

@end
