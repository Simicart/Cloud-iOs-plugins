//
//  SimiPayPalWorker.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayPalPayment.h"
#import "PayPalPaymentViewController.h"
#import "PayPalMobile.h"
#import <SimiCartBundle/SimiViewController.h>

@interface SimiPayPalWorker : NSObject<PayPalPaymentDelegate, UIAlertViewDelegate>

@end
