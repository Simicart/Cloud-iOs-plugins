//
//  MagentoInvoice.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/13/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoInvoice.h"

@implementation MagentoInvoice

#pragma mark - add signature for invoice
- (void)addSignature:(Invoice *)invoice withSign:(NSData *)image finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"order_invoice.signature" forKey:@"method"];
    [params setValue:[invoice objectForKey:@"increment_id"] forKey:@"params"];
    [params setValue:image forKey:@"signature"];
    [self post:params target:(NSObject *)invoice finished:finishedMethod async:NO];
}

#pragma mark - capture invoice
- (void)capture:(Invoice *)invoice finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"order_invoice.capture" forKey:@"method"];
    [params setValue:[invoice objectForKey:@"increment_id"] forKey:@"params"];
    [self post:params target:(NSObject *)invoice finished:finishedMethod async:NO];
}

#pragma mark - cancel invoice
- (void)cancel:(Invoice *)invoice finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"order_invoice.cancel" forKey:@"method"];
    [params setValue:[invoice objectForKey:@"increment_id"] forKey:@"params"];
    [self post:params target:(NSObject *)invoice finished:finishedMethod async:NO];
}

@end
