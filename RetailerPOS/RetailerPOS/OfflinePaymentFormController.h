//
//  OfflinePaymentFormController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 6/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "PaymentFormAbstract.h"

@interface OfflinePaymentFormController : PaymentFormAbstract

- (void)updateFormData:(NSNotification *)note;

@end
