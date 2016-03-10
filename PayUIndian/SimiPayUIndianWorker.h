//
//  SimiPayUIndianWorker.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 2/1/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayU_iOS_SDK.h"

@interface SimiPayUIndianWorker : NSObject<UIAlertViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSDictionary *hashDict;
@property (strong, nonatomic) UIPopoverController * popController;
@property (strong, nonatomic) NSMutableDictionary *paymentData;
@end
