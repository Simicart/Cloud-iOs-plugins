//
//  Order.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Order.h"
#import "MagentoOrder.h"
#import "MSValidator.h"

#import "QuoteItem.h"
#import "Product.h"
#import "Account.h"

@implementation Order

-(id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Order";
    }
    return self;
}

- (NSString *)getIncrementId
{
    id identify = [self objectForKey:@"increment_id"];
    if ([identify isKindOfClass:[NSNumber class]]) {
        return [identify stringValue];
    }
    return identify;
}

#pragma mark - repair abstract methods
- (void)loadSuccess
{
    [super loadSuccess];
    for (id key in [self allKeys]) {
        if ([[self objectForKey:key] isKindOfClass:[NSNull class]]) {
            [self removeObjectForKey:key];
        }
    }
    // Correct total due
    if ([self objectForKey:@"total_due"] == nil) {
        if ([self objectForKey:@"total_paid"]) {
            long double totalDue = [[self objectForKey:@"grand_total"] doubleValue];
            totalDue -= [[self objectForKey:@"total_paid"] doubleValue];
            totalDue += [[self objectForKey:@"total_refunded"] doubleValue];
            [self setValue:[NSNumber numberWithDouble:totalDue] forKey:@"total_due"];
        } else {
            [self setValue:[self objectForKey:@"grand_total"] forKey:@"total_due"];
        }
    }
    // Refresh linked object
    NSMutableArray *items = [NSMutableArray new];
    BOOL canRefundItem = NO;
    for (id key in [[self objectForKey:@"items"] allKeys]) {
        id obj = [[self objectForKey:@"items"] objectForKey:key];
        QuoteItem *item = [QuoteItem new];
        [item addData:obj];
        [item setValue:key forKey:@"id"];
        
        item.product = [Product new];
        [item.product addData:[item objectForKey:@"product_data"]];
        [item removeObjectForKey:@"product_data"];
        
        if ([[item objectForKey:@"selected_options"] isKindOfClass:[NSDictionary class]]) {
            item.options = [[NSMutableDictionary alloc] initWithDictionary:[item objectForKey:@"selected_options"]];
        }
        [item removeObjectForKey:@"selected_options"];
        
        [items addObject:item];
        if (!canRefundItem && [[item objectForKey:@"qty_invoiced"] floatValue] > [[item objectForKey:@"qty_refunded"] floatValue]) {
            canRefundItem = YES;
        }
    }
    [self setValue:[NSNumber numberWithBool:canRefundItem] forKey:@"can_refund_item"];
    [self setValue:items forKey:@"items"];
}

#pragma mark - send email
- (void)sendEmail:(NSString *)email
{
    if (email == nil || ![MSValidator validateEmail:email]) {
        email = [self objectForKey:@"customer_email"];
    }
    if (![MSValidator validateEmail:email]) {
        return;
    }
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];
    [resource sendEmail:self address:email finished:@selector(sendEmailSuccess)];
}

- (void)sendEmailSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderSendEmailSuccess" object:nil];
}

#pragma mark - invoice and refund
- (void)invoice:(NSDictionary *)invoiceData
{
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];
    [resource createInvoice:self withData:invoiceData finished:@selector(invoiceSuccess:)];
}

- (void)invoiceSuccess:(id)result
{
    if (![MSValidator isEmptyString:[result objectForKey:@"data"]]) {
        [self setValue:[result objectForKey:@"data"] forKey:@"last_invoice_id"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCreateInvoiceSuccess" object:nil];
}

- (void)creditmemo:(NSDictionary *)creditmemoData
{
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];
    [resource createCreditmemo:self withData:creditmemoData finished:@selector(creditmemoSuccess)];
}

- (void)creditmemoSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderRefundSuccess" object:nil];
}

#pragma mark - Cancel Order
- (void)cancel
{
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];
    [resource cancel:self finished:@selector(cancelSuccess)];
}

- (void)cancelSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCancelSuccess" object:nil];
}

#pragma mark - Cancel Order
- (void)ship
{
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];    
    [resource ship:self finished:@selector(shipSuccess)];
}

- (void)shipSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderShipSuccess" object:nil];
}


#pragma mark - comment for order
- (void)comment:(NSString *)comment
{
    if ([MSValidator isEmptyString:comment]) {
        return;
    }
    [self setValue:comment forKey:@"new_comment"];
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];
    [resource comment:self finished:@selector(commentSuccess)];
}

- (void)commentSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCommentSuccess" object:nil];
}

#pragma mark - check permission
- (BOOL)canInvoice
{
    /*
     "can_cancel" = 1;
     "can_invoice" = 1;
     "can_refund" = 0;
     "can_ship" = 1;
     */
    
    if([self objectForKey:@"can_invoice"]){
        return [[self objectForKey:@"can_invoice"] boolValue];
    }
    
    return NO;
}

- (BOOL)canRefund
{
    if([self objectForKey:@"can_refund"]){
        return [[self objectForKey:@"can_refund"] boolValue];
    }
    return NO;
}


-(void)disableRefund{
    [self setObject:[NSNumber numberWithBool:NO] forKey:@"can_refund"];
}

- (BOOL)canCancel
{
    if([self objectForKey:@"can_cancel"]){
        return [[self objectForKey:@"can_cancel"] boolValue];
    }
    
    return NO;
}

- (BOOL)canShip
{
    if([self objectForKey:@"can_ship"]){
        return [[self objectForKey:@"can_ship"] boolValue];
    }
    return NO;
}

- (BOOL)checkPermission:(NSInteger)value
{
    if (value == 4) {
        return NO;
    }
    if (value == 2) {
        return YES;
    }
    // With Other
    if ([MSValidator isEmptyString:[self objectForKey:@"simipos_email"]]) {
        return NO;
    }
    if (value == 1) {
        return YES;
    }
    // Owner
    if ([[self objectForKey:@"simipos_user"] integerValue] == [[[Account currentAccount] objectForKey:@"user_id"] integerValue]) {
        return YES;
    }
    return NO;
}

#pragma mark - load print data
- (void)loadPrintData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderLoadPrintBefore" object:self];
    [(MagentoOrder *)[self getResource] loadPrint:self finished:@selector(loadPrintDataSuccess)];
}

- (void)loadPrintDataSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderLoadPrintAfter" object:self];
}

//chiennd: on Hold
-(void)cancelHoldOrder{
    
    if (![self objectForKey:@"increment_id"]) {
        [self setValue:[self getId] forKey:@"increment_id"];
    }
    MagentoOrder *resource = (MagentoOrder *)[self getResource];
    [resource cancelHoldOrder:self finished:@selector(cancelHoldOderSuccess)];
}

- (void)cancelHoldOderSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyHoldOrderCancelSuccess" object:self];
}
@end
