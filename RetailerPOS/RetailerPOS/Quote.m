//
//  Quote.m
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/9/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Quote.h"
#import "QuoteResource.h"
#import "Configuration.h"
#import "MSFramework.h"

#import "ShippingCollection.h"
#import "PaymentCollection.h"

NSString *const QuoteWillRequestNotification = @"QuoteWillRequestNotification";
NSString *const QuoteDidRequestNotification = @"QuoteDidRequestNotification";
NSString *const QuoteEndRequestNotification = @"QuoteEndRequestNotification";

NSString *const QuoteFailtRequestNotification = @"QuoteFailtRequestNotification";

@interface Quote()
@property (nonatomic) NSUInteger loadQuoteItemState, numberOfUpdate;
- (void)changeQuoteData;
@end

@implementation Quote
@synthesize loadQuoteItemState, numberOfUpdate;

@synthesize customer = _customer;
@synthesize quoteItems = _quoteItems;
@synthesize totals = _totals;

@synthesize isShipped;
@synthesize shipping = _shipping;
@synthesize cashIn;
@synthesize payment = _payment;

@synthesize order = _order;

-(id)init {
    if (self = [super init]) {
        self.eventPrefix = @"Quote";
        self.customer = [Customer new];
        self.totals = [[NSMutableDictionary alloc] init];

        self.isShipped = BoolValue(KEY_CREATE_SHIPMENT);
        
        self.shipping = [Shipping new];
        self.shipping.collection = [ShippingCollection new];
        self.cashIn = 0.0;
        self.payment = [Payment new];
        self.payment.collection = [PaymentCollection new];
        
        self.numberOfUpdate = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failtRequestQuote:) name:@"QueryException" object:nil];
    }
    return self;
}

- (void)cleanData
{
    [self clearOrderIdSession];
    
    [self removeAllObjects];
    [self.customer removeAllObjects];
    [self.totals removeAllObjects];
    [self.quoteItems removeAllObjects];
    
    self.isShipped = BoolValue(KEY_CREATE_SHIPMENT);

    [self.shipping removeAllObjects];
    self.cashIn = 0.0;
    // Remember config for payment method
    id markAsPaid = [self.payment objectForKey:@"is_invoice"];
    [self.payment removeAllObjects];
    if (markAsPaid) {
        [self.payment setValue:markAsPaid forKey:@"is_invoice"];
    }
    
    self.order = nil;
    
    [self setValue:[NSNumber numberWithInteger:0] forKey:@"grand_total"];
}

- (void)failtRequestQuote:(NSNotification *)note
{
    id model = [[note userInfo] objectForKey:@"model"];
    if (model != nil && [model isKindOfClass:[QuoteResource class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QuoteFailtRequestNotification object:model];
        if ([((QuoteResource *)model).type isEqualToString:@"add"] && [[note userInfo] objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[[note userInfo] objectForKey:@"reason"]];
        }
    }
}

+(Quote *)sharedQuote {
    return (Quote *)[Configuration getSingleton:@"Quote"];
}

+(void)setQuote:(Quote*)quote{
    [Configuration setSingleton:@"Quote" WithValue:quote];
}

- (void)loadSuccess
{
    [super loadSuccess];
    // Change Configuration
    Configuration *config = [Configuration globalConfig];
    if (![[self getId] isEqualToString:[config objectForKey:@"quote_id"]]) {
        [config setValue:[self getId] forKey:@"quote_id"];
    }
    
    // Reload Customer
    if ([[self objectForKey:@"customer_id"] isKindOfClass:[NSNull class]]) {
        [self.customer removeAllObjects];
        return;
    }
    NSString *newId;
    if ([[self objectForKey:@"customer_id"] isKindOfClass:[NSNumber class]]) {
        newId = [[self objectForKey:@"customer_id"] stringValue];
    } else {
        newId = [self objectForKey:@"customer_id"];
    }
    if ([newId isEqualToString:[self.customer getId]]) {
        return;
    }
    [self.customer removeAllObjects];
    [self.customer setValue:[self objectForKey:@"customer_id"] forKey:@"id"];
    [self.customer setValue:[self objectForKey:@"customer_name"] forKey:@"name"];
    [self.customer setValue:[self objectForKey:@"customer_email"] forKey:@"email"];
    [self.customer setValue:[self objectForKey:@"customer_telephone"] forKey:@"telephone"];
    [self.customer setValue:[self objectForKey:@"customer_group_id"] forKey:@"group_id"];
}

- (void)changeQuoteData
{
    if ([self objectForKey:@"grand_total"] == nil) {
        [self load:nil];
        if ([self objectForKey:@"grand_total"] != nil) {
            [self loadQuoteItems];
        }
    }
}

#pragma mark - load objects methods
- (void)loadQuoteItems
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:self userInfo:nil];
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    [resource loadDataRequest:@"items"];
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:self userInfo:nil];
}

- (void)initQuoteItems:(NSDictionary *)resource
{
    // Init quote items
    [resource enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        QuoteItem *item = [self addItem:obj];
        if (item.product == nil) {
            item.product = [[Product alloc] init];
            [item.product addData:[item objectForKey:@"product_data"]];
            [item removeObjectForKey:@"product_data"];
        }
        if ([[item objectForKey:@"selected_options"] isKindOfClass:[NSDictionary class]]) {
            if (item.options == nil) {
                item.options = [[NSMutableDictionary alloc] initWithDictionary:[item objectForKey:@"selected_options"]];
            } else {
                [item.options addEntriesFromDictionary:[item objectForKey:@"selected_options"]];
            }
        }
        [item removeObjectForKey:@"selected_options"];
    }];
    self.loadQuoteItemState = 2;
    [self loadQuoteTotals];
}

- (void)loadQuoteTotals
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:self userInfo:nil];
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    [resource loadDataRequest:@"totals"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:self userInfo:nil];
}

- (void)initQuoteTotals:(NSDictionary *)resource
{
    // Init totals
    [self.totals removeAllObjects];
    if ([[resource allKeys] count]) {
        [self.totals addEntriesFromDictionary:resource];
    }
    for (id key in [self.totals allKeys]) {
        NSDictionary *total = [self.totals objectForKey:key];
        if ([[total objectForKey:@"amount"] isKindOfClass:[NSNull class]]
            || [[total objectForKey:@"code"] isEqualToString:@"rewardpoints_label"]
        ) {
            [self.totals removeObjectForKey:key];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteEndRequestNotification object:self userInfo:nil];
}

#pragma mark - Working with quote items
- (void)addCustomSale:(NSDictionary *)options
{
    Product *product = [[Product alloc] init];
    [product setValue:NSLocalizedString(@"Custom Sale", nil) forKey:@"name"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:product userInfo:nil];
    [self changeQuoteData];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    resource.product = product;
    resource.options = options;
    [resource addCustomSale];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
}

- (void)addProduct:(Product *)product withOptions:(NSDictionary *)options
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:product userInfo:nil];
    [self changeQuoteData];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    // Attach data to resource
    resource.product = product;
    if (options != nil) {
        resource.options = [options copy];
    }
    [resource updateItemRequest:[product getId] method:@"add"];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
}



- (void)updateItem:(id)itemId withOptions:(NSDictionary *)options
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    // Attach data to resource
    resource.itemId = itemId;
    if (options != nil) {
        resource.options = [options mutableDeepCopy];
    }
    [resource updateItemRequest:itemId method:@"update"];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:itemId userInfo:nil];
}

- (void)updateItemPrice:(id)itemId price:(id)price
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    resource.itemId = itemId;
    resource.customPrice = price;
    [resource updateItemRequest:itemId method:@"customPrice"];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:itemId userInfo:nil];
}

- (void)updateItemQty:(id)itemId qty:(CGFloat)qty
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    resource.itemId = itemId;
    resource.itemQty = [NSNumber numberWithFloat:qty];
    [resource updateItemRequest:itemId method:@"updateQty"];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:itemId userInfo:nil];
}

- (void)removeItem:(id)itemId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    resource.itemId = itemId;
    [resource updateItemRequest:itemId method:@"remove"];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:itemId userInfo:nil];
}

- (void)addByBarcode:(NSString *)barcode
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:nil userInfo:nil];
    [self changeQuoteData];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    [resource updateItemRequest:barcode method:@"barcode"];
    
    self.numberOfUpdate--;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:nil userInfo:nil];
}

- (void)editItemComplete:(QuoteResource *)resource
{
    if ([resource.type isEqualToString:@"barcode"]) {
        // Process barcode success
        NSDictionary *productData = [resource objectForKey:@"product_data"];
        [resource removeObjectForKey:@"product_data"];
        
        QuoteItem *item = [self addItem:resource];
        if (item.product == nil && productData) {
            item.product = [[Product alloc] init];
            [item.product addData:productData];
        }
        if (![self getId]) {
            [self load:nil];
        }
    } else
    // Explode data from resource (for adding) and add item (clone product data for item)
    if (resource.product != nil) {
        if (resource.options != nil && [resource.options count] > 1) {
            NSString *optionName = [[resource.options allKeys] objectAtIndex:0];
            if ([optionName rangeOfString:@"super_group" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                self.loadQuoteItemState = 1;
                [self loadQuoteItems];
                return;
            }
        }
        // Add new item or update exist item
        QuoteItem *item = [self addItem:resource];
        item.product = resource.product;
        if (resource.options != nil) {
            if (item.options == nil) {
                item.options = [[NSMutableDictionary alloc] initWithDictionary:resource.options];
            } else {
                [item.options removeAllObjects];
                [item.options addEntriesFromDictionary:resource.options];
            }
        }
        if (![self getId]) {
            [self load:nil];
        }
    } else if (resource.itemId != nil) {
        // Update for exist item
        QuoteItem *item = [self getItemById:resource.itemId];
        if (item != nil && resource.itemQty != nil) {
            [item addData:resource];
//            [item setValue:resource.itemQty forKey:@"qty"];
        } else if (item != nil && resource.customPrice != nil) {
            [item addData:resource];
        } else if (item != nil && resource.options != nil) {
            [item addData:resource];
            if (item.options == nil) {
                item.options = [[NSMutableDictionary alloc] initWithDictionary:resource.options];
            } else {
                [item.options removeAllObjects];
                [item.options addEntriesFromDictionary:resource.options];
            }
        } else if (item != nil) {
            // Remove item
            [self.quoteItems removeObject:item];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteEndRequestNotification object:self];
    if (self.numberOfUpdate > 1) {
        if (self.loadQuoteItemState) {
            self.loadQuoteItemState = 2;
        }
        return;
    }
    if (self.loadQuoteItemState == 0) {
        self.loadQuoteItemState = 1;
        [self loadQuoteItems];
    } else {
        self.loadQuoteItemState = 2;
        // [self loadQuoteTotals];
        QuoteResource *resource = [[QuoteResource alloc] init];
        [resource loadDataRequest:@"totals"];
    }
}

#pragma mark - Remove current Order Id
-(void)clearOrderIdSession{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:KEY_USERD_DEFAULT_ORDERID];
    [defaults synchronize];
}

- (void)clearCart
{
    //Remove current Order Id
    [self clearOrderIdSession];
    
    if ([self totalItemsQty] == 0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:self userInfo:nil];
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    [resource loadDataRequest:@"clear"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:self userInfo:nil];
}

- (void)clearCartSuccess:(QuoteResource *)resource
{
    if (self.quoteItems != nil) {
        [self.quoteItems removeAllObjects];
    }
    [self.totals removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteEndRequestNotification object:self userInfo:nil];
}

#pragma mark - Get Data
- (CGFloat)totalItemsQty
{
    if (self.quoteItems == nil) {
        return 0;
    }
    CGFloat totalQty = 0;
    // Collect total item qty
    for (QuoteItem *item in self.quoteItems) {
        totalQty += [item getQty];
    }
    return totalQty;
}

- (QuoteItem *)getItemById:(id)itemId
{
    if (self.quoteItems == nil) {
        return nil;
    }
    if ([itemId isKindOfClass:[NSNumber class]]) {
        itemId = [itemId stringValue];
    }
    for (QuoteItem *item in self.quoteItems) {
        if ([[item getId] isEqualToString:(NSString *)itemId]) {
            return item;
        }
    }
    return nil;
}

- (QuoteItem *)addItem:(NSDictionary *)itemData
{
    QuoteItem *item = [self getItemById:[itemData objectForKey:@"id"]];
    if (item != nil) {
        [item addData:itemData];
        return item;
    }
    item = [[QuoteItem alloc] init];
    [item addData:itemData];
    if (self.quoteItems == nil) {
        self.quoteItems = [[NSMutableArray alloc] init];
    }
    [self.quoteItems addObject:item];
    return item;
}

- (NSArray *)getAllItems
{
    return self.quoteItems;
}

- (NSArray *)getTotals
{
    NSMutableArray *totals = [[NSMutableArray alloc] init];
    NSArray *sortedKey = [[self.totals allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (id key in sortedKey) {
        id obj = [self.totals objectForKey:key];
        if ([[obj objectForKey:@"code"] isEqualToString:@"grand_total"]) {
            continue;
        }
        [totals addObject:obj];
    }
    return totals;
}

- (NSNumber *)getGrandTotal
{
    for (id obj in [self.totals allValues]) {
        if ([[obj objectForKey:@"code"] isEqualToString:@"grand_total"]) {
            return [obj objectForKey:@"amount"];
        }
    }
    return [NSNumber numberWithInt:0];
}

#pragma mark - Customer/ Address methods
- (BOOL)hasCustomer
{
    if ([self.customer getId]) {
        return [[self.customer getId] boolValue];
    }
    return NO;
}

- (void)assignCustomer:(Customer *)customer
{
    if ([[self objectForKey:@"customer_id"] isKindOfClass:[NSNull class]]
        && customer == nil
    ) {
        return;
    }
    NSInteger currentCustomerId = 0;
    if (![[self objectForKey:@"customer_id"] isKindOfClass:[NSNull class]]) {
        currentCustomerId = [[self objectForKey:@"customer_id"] integerValue];
    }
    if (customer != nil
        && [[customer getId] integerValue] == currentCustomerId
    ) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:self userInfo:nil];
    [self changeQuoteData];
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    resource.customer = customer;
    [resource assignCustomer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:self userInfo:nil];
}

- (void)forceAssignCustomer:(Customer *)customer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:self userInfo:nil];
    [self changeQuoteData];
    
    QuoteResource *resource = [[QuoteResource alloc] init];
    resource.customer = customer;
    [resource assignCustomer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:self userInfo:nil];
}

- (void)assignCustomerComplete:(QuoteResource *)resource
{
    if (![self getId]) {
        [self load:nil];
    }
    if (resource.customer == nil) {
        [self.customer removeAllObjects];
        [self setValue:[NSNull new] forKey:@"customer_id"];
        [self setValue:@"0" forKey:@"customer_group_id"];
        [self setValue:[NSNull new] forKey:@"customer_email"];
        [self setValue:@" " forKey:@"customer_telephone"];
        [self setValue:@" " forKey:@"customer_name"];
        [self loadQuoteItems];
        return;
    }
    
    [self.customer addData:resource.customer];
    [self setValue:[self.customer getId] forKey:@"customer_id"];
    [self setValue:[self.customer objectForKey:@"email"] forKey:@"customer_email"];
    [self setValue:[self.customer objectForKey:@"telephone"] forKey:@"customer_telephone"];
    [self setValue:[self.customer objectForKey:@"name"] forKey:@"customer_name"];
    
    if ([[self objectForKey:@"customer_group_id"] integerValue] != [[self.customer objectForKey:@"group_id"] integerValue]) {
        [self setValue:[self.customer objectForKey:@"group_id"] forKey:@"customer_group_id"];
        [self loadQuoteItems];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteEndRequestNotification object:self userInfo:nil];
}

#pragma mark - Place order
- (void)placeOrder:(NSDictionary *)config
{
    // Place Order with Config: is_shipped, is_invoice, cash_in
    QuoteResource *resource = [QuoteResource new];
    [resource placeOrder:config];
}

- (void)placeOrderComplete:(QuoteResource *)resource
{
    // Update Order Information
    if (self.order == nil && [resource objectForKey:@"order"]) {
        self.order = [Order new];
        [self.order addData:resource];
        [self.order setValue:[resource objectForKey:@"order"] forKey:@"id"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuotePlaceOrderSuccess" object:nil];
}


#pragma mark -  ****** METHOD OFFLINE *******

- (void)addProductOffline:(Product *)product withOptions:(NSDictionary *)options
{
    QuoteItem *item = [self getItemById:[product objectForKey:@"id"]];
    if (item != nil) {
        item.product =product;
        
        int qty = [[item objectForKey:@"qty"] intValue];
        [item setObject:[NSString stringWithFormat:@"%d",qty +1] forKey:@"qty"];
        
        item.options = [[NSMutableDictionary alloc] initWithDictionary:options];
         [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
        return ;
    }

    item = [[QuoteItem alloc] init];
    [item addData:product];
    item.product =product;
    [item setObject:@"1" forKey:@"qty"];
     item.options = [[NSMutableDictionary alloc] initWithDictionary:options];
    
    if (self.quoteItems == nil) {
        self.quoteItems = [[NSMutableArray alloc] init];
    }
    [self.quoteItems addObject:item];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
}

#pragma mark - addCustomSaleOffline
- (void)addCustomSaleOffline:(NSDictionary *)options
{
    Product *product = [[Product alloc] init];
    [product setValue:[NSString stringWithFormat:@"[Custom Sale] %@",[options objectForKey:@"name"]] forKey:@"name"];
    [product setValue:[options objectForKey:@"is_virtual"] forKey:@"is_virtual"];
    [product setValue:[options objectForKey:@"price"] forKey:@"price"];
    
    [product setValue:@"1" forKey:@"qty"];
    [product setValue:@"Custom Sale" forKey:@"short_description"];
    [product setValue:@"" forKey:@"sku"];
    [product setValue:[NSArray new] forKey:@"options"];
    [product setValue:@"CustomSaleID" forKey:@"id"];
    
    //[self addProductOffline:product withOptions:options];
    QuoteItem *item = [self getItemById:[product objectForKey:@"id"]];
    if (item != nil) {
        [item setData:product];
        item.product =product;
        [item setObject:@"1" forKey:@"qty"];
        item.options = [[NSMutableDictionary alloc] initWithDictionary:options];
        [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
        return ;
    }
    
    item = [[QuoteItem alloc] init];
    [item addData:product];
    item.product =product;
    [item setObject:@"1" forKey:@"qty"];
    [item setObject:[product objectForKey:@"id"] forKey:@"id"];
    item.options = [[NSMutableDictionary alloc] initWithDictionary:options];
    
    if (self.quoteItems == nil) {
        self.quoteItems = [[NSMutableArray alloc] init];
    }
    [self.quoteItems addObject:item];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
    
}

#pragma mark - addDiscountOffline
- (void)addDiscountOffline:(NSDictionary *)options
{
    Product *product = [[Product alloc] init];
    [product setValue:[NSString stringWithFormat:@"[Discount] %@",[options objectForKey:@"name"]] forKey:@"name"];
    
    float amountDiscount = (-1)*[[options objectForKey:@"price"] floatValue];
    
    [product setValue:[NSString stringWithFormat:@"%f",amountDiscount] forKey:@"price"];
     [product setValue:[options objectForKey:@"inputtype"] forKey:@"inputtype"];
    
    [product setValue:@"1" forKey:@"qty"];
    [product setValue:@"" forKey:@"sku"];
    [product setValue:[NSArray new] forKey:@"options"];
    [product setValue:@"DiscountID" forKey:@"id"];
    
    QuoteItem *item = [self getItemById:[product objectForKey:@"id"]];
    if (item != nil) {
        [item setData:product];
        item.product =product;
        [item setObject:@"1" forKey:@"qty"];
        item.options = [[NSMutableDictionary alloc] initWithDictionary:options];
        [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
        return ;
    }
    
    item = [[QuoteItem alloc] init];
    [item addData:product];
    item.product =product;
    [item setObject:@"1" forKey:@"qty"];
    [item setObject:[product objectForKey:@"id"] forKey:@"id"];
    item.options = [[NSMutableDictionary alloc] initWithDictionary:options];
    
    if (self.quoteItems == nil) {
        self.quoteItems = [[NSMutableArray alloc] init];
    }
    [self.quoteItems addObject:item];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
    
}

- (QuoteItem *)addItemOffline:(Product *)product
{
    QuoteItem *item = [self getItemById:[product objectForKey:@"id"]];
    if (item != nil) {
        return item;
    }
    item = [[QuoteItem alloc] init];
    [item addData:product];
    [item setObject:@"1" forKey:@"qty"];    
    
    if (self.quoteItems == nil) {
        self.quoteItems = [[NSMutableArray alloc] init];
    }
    [self.quoteItems addObject:item];
    return item;
}

-(NSNumber *)getGrandTotalOffline{
    if(self.quoteItems && self.quoteItems.count >0){
        float grandTotal =0;
        
        for(QuoteItem * item in self.quoteItems){
            
            NSString * price =[NSString stringWithFormat:@"%@",[item objectForKey:@"price"]];
            NSString * qty = [NSString stringWithFormat:@"%@",[item objectForKey:@"qty"]];
            float itemTotal =price.floatValue * qty.floatValue;
            
            grandTotal += itemTotal;
        }

        return [NSNumber numberWithFloat:grandTotal];
    }
    return 0;
}

-(void)removeItemOfline:(QuoteItem *)quoteItem
{
    [self.quoteItems removeObject:quoteItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NofityUpdateTotalPrice" object:nil];
}

-(void)assignCustomerOffline:(Customer *)customer
{
    self.customer = customer;
    
    if(customer && [customer objectForKey:@"name"]){
      [self setObject:[customer objectForKey:@"name"] forKey:@"customer_name"];
    }
    
    if( customer && [customer objectForKey:@"telephone"]){
       [self setObject:[customer objectForKey:@"telephone"] forKey:@"customer_telephone"];
    }
    
    if( customer && [customer objectForKey:@"email"]){
      [self setObject:[customer objectForKey:@"email"] forKey:@"customer_email"];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:self userInfo:nil];
}

@end
