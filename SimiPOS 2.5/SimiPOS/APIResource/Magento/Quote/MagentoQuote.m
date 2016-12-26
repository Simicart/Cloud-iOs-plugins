//
//  MagentoQuote.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoQuote.h"

@implementation MagentoQuote

#pragma mark - implement abstract
-(NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"checkout_cart.info" forKey:@"method"];
    return params;
}

-(void)load:(ModelAbstract *)object withId:(NSObject *)identify finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [self prepareLoad:object];
    [self post:params target:(NSObject *)object finished:finishedMethod async:NO];
}

#pragma mark - Load data request
-(void)loadItems:(QuoteResource *)resource finished:(SEL)finishedMethod
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"checkout_cart.items", @"method", nil];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)loadTotals:(QuoteResource *)resource finished:(SEL)finishedMethod
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"checkout_cart.totals", @"method", nil];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)clearCart:(QuoteResource *)resource finished:(SEL)finishedMethod
{
    NSDictionary *params = @{@"method": @"checkout_product.clear"};
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

#pragma mark - Update product items request
- (void)addCustomSale:(QuoteResource *)resource withOptions:(NSDictionary *)options finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_product.addCustom" forKey:@"method"];
    [params setValue:@[options] forKey:@"params"];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)addProduct:(QuoteResource *)resource productId:(NSString *)productId withOptions:(NSDictionary *)options finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_product.add" forKey:@"method"];
    
    NSMutableDictionary *productData;
    if (options) {
        productData = [[NSMutableDictionary alloc] initWithDictionary:options];
    } else {
        productData = [[NSMutableDictionary alloc] init];
    }
    [productData setValue:productId forKey:@"id"];
    
    [params setValue:[NSArray arrayWithObject:productData] forKey:@"params"];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

- (void)addByBarcode:(QuoteResource *)resource barcode:(NSString *)barcode finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_product.addBarcode" forKey:@"method"];
    [params setValue:@[barcode] forKeyPath:@"params"];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)updateItem:(QuoteResource *)resource itemId:(id)itemId withOptions:(NSDictionary *)options finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_product.update" forKey:@"method"];
    
    [params setValue:[NSArray arrayWithObjects:itemId, options, nil] forKey:@"params"];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)updateItemPrice:(QuoteResource *)resource itemId:(id)itemId price:(id)price finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_product.price" forKey:@"method"];
    
    [params setValue:@[itemId, price] forKey:@"params"];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)updateItemQty:(QuoteResource *)resource itemId:(id)itemId qty:(NSNumber *)qty finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_product.qty" forKey:@"method"];
    
    [params setValue:@[itemId, qty] forKey:@"params"];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

-(void)removeItem:(QuoteResource *)resource itemId:(id)itemId finished:(SEL)finishedMethod
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"checkout_product.remove", @"method", itemId, @"params", nil];
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

#pragma mark - Customer and address
-(void)assignCustomer:(QuoteResource *)resource customer:(Customer *)customer finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_customer.set" forKey:@"method"];
    
    if (customer == nil) {
        [params setValue:@[@{@"mode": @"guest"}] forKey:@"params"];
    } else {
        [params setValue:@[@{@"mode": @"customer", @"id": [customer getId]}] forKey:@"params"];
    }
    
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

#pragma mark - Place order
- (void)placeOrder:(QuoteResource *)resource withConfig:(NSDictionary *)config finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"checkout_cart.createOrder" forKey:@"method"];
    if (config) {
        [params setValue:@[config] forKey:@"params"];
    }
    
    NSString * orderId =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERD_DEFAULT_ORDERID]];
    [params setValue:orderId forKey:@"hold_order_id"];
    
    DLog(@"params:%@",params);
    
    [self post:params target:(NSObject *)resource finished:finishedMethod async:NO];
}

@end
