//
//  CreditCardSignViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPaintView.h"

@interface CreditCardSignViewController : UIViewController

@property (strong, nonatomic) MSPaintView *signView;

- (void)clearSignature;
- (void)submitSignature;
- (void)submitSignatureThread;

- (NSString *)imagePath:(NSString *)orderId;

@end
