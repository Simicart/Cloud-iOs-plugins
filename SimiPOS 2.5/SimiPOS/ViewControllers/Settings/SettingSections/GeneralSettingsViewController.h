//
//  GeneralSettingsViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNumberPadString.h"

@interface GeneralSettingsViewController : UITableViewController <UITextFieldDelegate, MSNumberPadStringDelegate>

- (void)changeHideDemoValue:(id)sender;

@end