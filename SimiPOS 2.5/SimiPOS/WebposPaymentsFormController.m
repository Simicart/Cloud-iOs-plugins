//
//  PurchaseOrderFormController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/28/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "WebposPaymentsFormController.h"

@implementation WebposPaymentsFormController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.form.rowHeight = 54;
    
    // Initial Form Fields
    [self.form addField:@"Number" config:@{
        @"name": @"ref_no",
        @"title": NSLocalizedString(@"Reference No", nil),
        @"height": [NSNumber numberWithFloat:self.form.rowHeight]
    }];
    [self.form addField:@"Boolean" config:@{
        @"name": @"is_invoice",
        @"title": NSLocalizedString(@"Mark as Paid?", nil),
        @"required": [NSNumber numberWithBool:NO],
        @"height": [NSNumber numberWithFloat:self.form.rowHeight]
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFormData:) name:@"MSFormUpdateData" object:nil];
}

- (void)updateFormData:(NSNotification *)note
{
    id sender = [note object];
    if (sender == nil
        || ![sender isEqual:self.form]
        ) {
        return;
    }
    [self updatePaymentData];
    [self.checkout reloadButtonStatus];
}

@end
