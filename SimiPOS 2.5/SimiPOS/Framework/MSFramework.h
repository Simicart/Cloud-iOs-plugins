//
//  MSFramework.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/4/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Utilities.h"
#import "MSMutableDictionary.h"

#import "NSArray+MutableDeepCopy.h"
#import "NSDictionary+MutableDeepCopy.h"
#import "UIView+InputNotification.h"

#import "MSNavigationController.h"

#import "UIImage+ImageColor.h"
#import "UIColor+SimiPOS.h"

#import "MSGrayButton.h"
#import "MSBlueButton.h"
#import "MSBackButton.h"
#import "MSClearButton.h"
#import "MSNoteButton.h"
#import "MSRoundedButton.h"

#import "MSNumberPad.h"
#import "MSTextField.h"
#import "MSForm.h"
#import "MSValidator.h"
#import "MSPaintView.h"
#import "MSLock.h"
#import "MSHTTPRequest.h"
#import "MSDateTime.h"
#import "MSSegmentedControl.h"

#import "MSTableViewCell.h"
#import "MSCheckbox.h"

@interface MSFramework : NSObject

+ (BOOL)isIOS8;

@end
