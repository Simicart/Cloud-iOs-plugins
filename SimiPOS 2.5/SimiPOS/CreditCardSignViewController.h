//
//  CreditCardSignViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
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
