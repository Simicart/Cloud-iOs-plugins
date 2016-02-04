//
//  SCEmailContactWorker.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *LEFTMENU_ROW_CONTACTUS = @"LEFTMENU_ROW_CONTACTUS";

@interface SCEmailContactWorker : NSObject<UIPopoverControllerDelegate>
@property (nonatomic, strong) UIPopoverController *popController;
@end
