//
//  MagentoInvoice.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/13/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
#import "Invoice.h"

@interface MagentoInvoice : MagentoAbstract

- (void)addSignature:(Invoice *)invoice withSign:(NSData *)image finished:(SEL)finishedMethod;

- (void)capture:(Invoice *)invoice finished:(SEL)finishedMethod;
- (void)cancel:(Invoice *)invoice finished:(SEL)finishedMethod;

@end
