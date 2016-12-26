//
//  MagentoInvoice.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2016/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
#import "Invoice.h"

@interface MagentoInvoice : MagentoAbstract

- (void)addSignature:(Invoice *)invoice withSign:(NSData *)image finished:(SEL)finishedMethod;

- (void)capture:(Invoice *)invoice finished:(SEL)finishedMethod;
- (void)cancel:(Invoice *)invoice finished:(SEL)finishedMethod;

@end
