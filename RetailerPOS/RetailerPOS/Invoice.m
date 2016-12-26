//
//  Invoice.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Invoice.h"
#import "MagentoInvoice.h"

@implementation Invoice

#pragma mark - add signature for invoice
- (void)addSignature:(NSData *)image
{
    MagentoInvoice *resource = (MagentoInvoice *)[self getResource];
    [resource addSignature:self withSign:image finished:@selector(addSignatureSuccess)];
}

- (void)addSignatureSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InvoiceAddSignSuccess" object:nil];
}

#pragma mark - capture
- (void)capture
{
    MagentoInvoice *resource = (MagentoInvoice *)[self getResource];
    [resource capture:self finished:@selector(captureSuccess)];
}

- (void)captureSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InvoiceCaptureSuccess" object:nil];
}

#pragma mark - cancel
- (void)cancel
{
    MagentoInvoice *resource = (MagentoInvoice *)[self getResource];
    [resource cancel:self finished:@selector(cancelSuccess)];
}

- (void)cancelSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InvoiceCancelSuccess" object:nil];
}

@end
