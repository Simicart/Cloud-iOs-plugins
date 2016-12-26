//
//  CreditCardFormController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/28/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentFormAbstract.h"

@interface CreditCardFormController : PaymentFormAbstract

- (void)swipeCreditCardInput:(id)sender;
- (void)unserializeCCInfo;

- (void)startCheckout;
- (void)backToShopping;
- (void)listenCreditCardReader:(NSNotification *)note;

- (void)resizeCreditCardHeight:(NSNotification *)note;
- (void)returnCreditCardHeight:(NSNotification *)note;

- (void)updateFormData:(NSNotification *)note;

@end
