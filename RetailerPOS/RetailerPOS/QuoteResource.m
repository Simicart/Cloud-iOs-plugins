//
//  QuoteResource.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/31/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "QuoteResource.h"
#import "MagentoQuote.h"

@implementation QuoteResource
@synthesize type = _type;

@synthesize itemId;
@synthesize product;
@synthesize options;
@synthesize itemQty;
@synthesize customPrice;

@synthesize customer;
@synthesize config = _config;

- (id)init
{
    if (self = [super init]) {
        self.resourceClass = @"Quote";
    }
    return self;
}

#pragma mark - load data methods
- (void)loadDataRequest:(NSString *)type
{
    self.type = type;
    MagentoQuote *resource = (MagentoQuote *)[self getResource];
    if ([type isEqualToString:@"items"]) {
        [resource loadItems:self finished:@selector(loadDataSuccess)];
    } else if ([type isEqualToString:@"totals"]) {
        [resource loadTotals:self finished:@selector(loadDataSuccess)];
    } else {
        [resource clearCart:self finished:@selector(loadDataSuccess)];
    }
}

- (void)loadDataSuccess
{
    if ([self.type isEqualToString:@"items"]) {
        [[Quote sharedQuote] initQuoteItems:self];
    } else if ([self.type isEqualToString:@"totals"]) {
        [[Quote sharedQuote] initQuoteTotals:self];
    } else {
        [[Quote sharedQuote] clearCartSuccess:self];
    }
}

#pragma mark - update items methods
- (void)addCustomSale
{
    self.type = @"custom_sale";
    MagentoQuote *resource = (MagentoQuote *)[self getResource];
    [resource addCustomSale:self withOptions:options finished:@selector(addCustomSaleSuccess)];
}

- (void)addCustomSaleSuccess
{
    self.options = nil;
    [self updateItemSuccess];
}

- (void)updateItemRequest:(id)identify method:(NSString *)method
{
    self.type = method;
    MagentoQuote *resource = (MagentoQuote *)[self getResource];
    if ([method isEqualToString:@"add"]) {
        [resource addProduct:self productId:(NSString *)identify withOptions:options finished:@selector(updateItemSuccess)];
    } else if ([method isEqualToString:@"barcode"]) {
        [resource addByBarcode:self barcode:(NSString *)identify finished:@selector(updateItemSuccess)];
    } else if ([method isEqualToString:@"update"]) {
        [resource updateItem:self itemId:identify withOptions:options finished:@selector(updateItemSuccess)];
    } else if ([method isEqualToString:@"updateQty"]) {
        [resource updateItemQty:self itemId:identify qty:self.itemQty finished:@selector(updateItemSuccess)];
    } else if ([method isEqualToString:@"customPrice"]) {
        [resource updateItemPrice:self itemId:identify price:self.customPrice finished:@selector(updateItemSuccess)];
    } else {
        [resource removeItem:self itemId:identify finished:@selector(updateItemSuccess)];
    }
}

- (void)updateItemSuccess
{
    [[Quote sharedQuote] editItemComplete:self];
}

#pragma mark - customer and address
- (void)assignCustomer
{
    self.type = @"customer";
    MagentoQuote *resource = (MagentoQuote *)[self getResource];
    [resource assignCustomer:self customer:self.customer finished:@selector(assignCustomerComplete)];
}

- (void)assignCustomerComplete
{
    [[Quote sharedQuote] assignCustomerComplete:self];
}

#pragma mark - place order
- (void)placeOrder:(NSDictionary *)config
{
    self.type = @"order";
    self.config = config;
    MagentoQuote *resource = (MagentoQuote *)[self getResource];
    [resource placeOrder:self withConfig:self.config finished:@selector(placeOrderComplete)];
}

- (void)placeOrderComplete
{
    [[Quote sharedQuote] placeOrderComplete:self];
}

@end
