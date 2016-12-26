//
//  Invoice.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/12/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Invoice : ModelAbstract

- (void)addSignature:(NSData *)image;
- (void)addSignatureSuccess;

- (void)capture;
- (void)captureSuccess;

- (void)cancel;
- (void)cancelSuccess;

@end
