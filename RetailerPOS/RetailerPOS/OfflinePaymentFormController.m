//
//  OfflinePaymentFormController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 6/8/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "OfflinePaymentFormController.h"

@implementation OfflinePaymentFormController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.form.rowHeight = 54;
    
    // Initial Form Fields
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
