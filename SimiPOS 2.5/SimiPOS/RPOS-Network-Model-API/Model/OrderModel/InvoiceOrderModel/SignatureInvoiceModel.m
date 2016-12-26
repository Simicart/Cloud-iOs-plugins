//
//  SignatureInvoiceModel.m
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SignatureInvoiceModel.h"
#import "SignatureInvoiceAPI.h"

@implementation SignatureInvoiceModel

- (void)addSignatureInvoiceWith:(NSString*)invoiceID signatureData:(NSData*)signatureData{
    currentNotificationName = @"DidAddSignatureInvoiceWith";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@",[signatureData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
    
    Configuration *config = [Configuration globalConfig];
    NSString * currentSession =[config objectForKey:@"session"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentSession forKey:@"session"];
    [params setValue:@"order_invoice.signature" forKey:@"method"];
    [params setValue:signatureStr forKey:@"signature"];
    [params setValue:invoiceID forKey:@"params"];
    
    [(SignatureInvoiceAPI *) [self getAPI] addSignatureInvoiceWithParams:params method:@"POST" target:self selector:@selector(didFinishRequest:responder:)];
}

@end
