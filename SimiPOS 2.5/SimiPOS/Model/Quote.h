//
//  Quote.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelAbstract.h"
#import "QuoteItem.h"
#import "Customer.h"
#import "Shipping.h"
#import "Payment.h"
#import "Product.h"
#import "Order.h"

extern NSString *const QuoteWillRequestNotification;
extern NSString *const QuoteDidRequestNotification;
extern NSString *const QuoteEndRequestNotification;

extern NSString *const QuoteFailtRequestNotification;

@class QuoteResource;
@class Shipping;
@class Payment;

@interface Quote : ModelAbstract

-(void)cleanData;

+(Quote *)sharedQuote;
+(void)setQuote:(Quote*)quote;

- (void)failtRequestQuote:(NSNotification *)note;

// Linked Objects
@property (strong, nonatomic) Customer *customer;
@property (strong, nonatomic) NSMutableArray *quoteItems;
@property (strong, nonatomic) NSMutableDictionary *totals;

// Load objects from server
- (void)loadQuoteItems;
- (void)initQuoteItems:(NSDictionary *)resource;
- (void)loadQuoteTotals;
- (void)initQuoteTotals:(NSDictionary *)resource;

// Add product to cart, Update/Remove Items from cart
- (void)addCustomSale:(NSDictionary *)options;
- (void)addProduct:(Product *)product withOptions:(NSDictionary *)options;
- (void)addByBarcode:(NSString *)barcode;
- (void)updateItem:(id)itemId withOptions:(NSDictionary *)options;
- (void)updateItemPrice:(id)itemId price:(id)price;
- (void)updateItemQty:(id)itemId qty:(CGFloat)qty;
- (void)removeItem:(id)itemId;
- (void)editItemComplete:(QuoteResource *)resource;

- (void)clearCart;
- (void)clearCartSuccess:(QuoteResource *)resource;

//Ravi
- (void)getItemsAndTotals;
//End

// Get data
- (CGFloat)totalItemsQty;
- (QuoteItem *)getItemById:(id)itemId;
- (QuoteItem *)addItem:(NSDictionary *)itemData;
- (NSArray *)getAllItems;
- (NSArray *)getTotals;
- (NSNumber *)getGrandTotal;
//Ravi
- (NSNumber *)getShipping;
//End

// Customer and address
- (BOOL)hasCustomer;
- (void)assignCustomer:(Customer *)customer;
- (void)forceAssignCustomer:(Customer *)customer;
- (void)assignCustomerComplete:(QuoteResource *)resource;

// Shipping and Payment
@property (nonatomic) BOOL isShipped;
@property (strong, nonatomic) Shipping *shipping;
@property (nonatomic) long double cashIn;
@property (strong, nonatomic) Payment *payment;

// Place order
@property (strong, nonatomic) Order *order;
- (void)placeOrder:(NSDictionary *)config;
- (void)placeOrderComplete:(QuoteResource *)resource;

@end
