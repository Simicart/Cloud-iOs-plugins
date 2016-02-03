//
//  BarCodeWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/16/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiNavigationController.h>
#import "BarCodeViewController.h"
static NSString *LEFTMENU_ROW_BARCODE = @"LEFTMENU_ROW_BARCODE";

@interface BarCodeWorker : NSObject
@property (nonatomic, strong) BarCodeViewController* barCodeViewController;
@end
