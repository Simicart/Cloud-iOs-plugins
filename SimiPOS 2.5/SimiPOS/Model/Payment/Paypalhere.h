//
//  Paypalhere.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/15/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@class CheckoutViewController;

@interface Paypalhere : NSObject

+ (Paypalhere *)sharedModel;

- (void)openPaypalHereApp:(CheckoutViewController *)checkoutVC;

- (void)processPayment:(NSURL *)url;

@end
