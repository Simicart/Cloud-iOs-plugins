//
//  SettingSectionsViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/31/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingFormViewController.h"
#import "MSFramework.h"

@interface SettingSectionsViewController : UITableViewController
@property (strong, nonatomic) MSNavigationController *settingForms;

@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) UIViewController *currentSetting;

@end
