//
//  MagentoQuote.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
#import "QuoteResource.h"
#import "Customer.h"

@interface MagentoQuote : MagentoAbstract

// Load data request
-(void)loadItems:(QuoteResource *)resource finished:(SEL)finishedMethod;
-(void)loadTotals:(QuoteResource *)resource finished:(SEL)finishedMethod;

-(void)clearCart:(QuoteResource *)resource finished:(SEL)finishedMethod;

// Update product item request
-(void)addCustomSale:(QuoteResource *)resource withOptions:(NSDictionary *)options finished:(SEL)finishedMethod;
-(void)addProduct:(QuoteResource *)resource productId:(NSString *)productId withOptions:(NSDictionary *)options finished:(SEL)finishedMethod;
-(void)addByBarcode:(QuoteResource *)resource barcode:(NSString *)barcode finished:(SEL)finishedMethod;
-(void)updateItem:(QuoteResource *)resource itemId:(id)itemId withOptions:(NSDictionary *)options finished:(SEL)finishedMethod;
-(void)updateItemPrice:(QuoteResource *)resource itemId:(id)itemId price:(id)price finished:(SEL)finishedMethod;
-(void)updateItemQty:(QuoteResource *)resource itemId:(id)itemId qty:(NSNumber *)qty finished:(SEL)finishedMethod;
-(void)removeItem:(QuoteResource *)resource itemId:(id)itemId finished:(SEL)finishedMethod;

// Customer and address
-(void)assignCustomer:(QuoteResource *)resource customer:(Customer *)customer finished:(SEL)finishedMethod;

// Place Order
-(void)placeOrder:(QuoteResource *)resource withConfig:(NSDictionary *)config finished:(SEL)finishedMethod;

@end
