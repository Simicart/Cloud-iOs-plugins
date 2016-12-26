//
//  GeneralSettingsViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/31/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNumberPad.h"

@interface GeneralSettingsViewController : UITableViewController <UITextFieldDelegate, MSNumberPadDelegate>

- (void)changeHideDemoValue:(id)sender;

@end
