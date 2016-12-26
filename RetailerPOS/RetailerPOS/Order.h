//
//  Order.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/9/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Order : ModelAbstract

- (NSString *)getIncrementId;

- (void)sendEmail:(NSString *)email;
- (void)sendEmailSuccess;

// Invoice and creditmemo
- (void)invoice:(NSDictionary *)invoiceData;
- (void)invoiceSuccess:(id)result;

- (void)creditmemo:(NSDictionary *)creditmemoData;
- (void)creditmemoSuccess;

- (void)cancel;
- (void)cancelSuccess;

- (void)ship;
- (void)shipSuccess;

// Comment order
- (void)comment:(NSString *)comment;
- (void)commentSuccess;

// Permission
- (BOOL)canInvoice;

- (BOOL)canRefund;
-(void)disableRefund;
    
- (BOOL)canCancel;
- (BOOL)canShip;

- (BOOL)checkPermission:(NSInteger)value;

// Load Print Data
- (void)loadPrintData;
- (void)loadPrintDataSuccess;

//on Hold
-(void)cancelHoldOrder;

@end
