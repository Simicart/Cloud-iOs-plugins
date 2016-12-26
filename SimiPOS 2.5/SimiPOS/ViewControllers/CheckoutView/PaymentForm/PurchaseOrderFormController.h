//
//  PurchaseOrderFormController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/28/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentFormAbstract.h"

@interface PurchaseOrderFormController : PaymentFormAbstract

- (void)updateFormData:(NSNotification *)note;

@end
