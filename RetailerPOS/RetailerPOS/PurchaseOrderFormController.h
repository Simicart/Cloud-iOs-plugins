//
//  PurchaseOrderFormController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/28/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentFormAbstract.h"

@interface PurchaseOrderFormController : PaymentFormAbstract

- (void)updateFormData:(NSNotification *)note;

@end
