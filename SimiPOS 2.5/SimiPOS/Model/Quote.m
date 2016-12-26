//
//  Quote.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Quote.h"
#import "QuoteResource.h"
#import "Configuration.h"
#import "MSFramework.h"

#import "ShippingCollection.h"
#import "PaymentCollection.h"

//Ravi
#import "AddToCartModel.h"
#import "ItemsCartModel.h"
#import "TotalsCartModel.h"
#import "AssignCustomerModel.h"
#import "DeleteItemCartModel.h"
#import "ClearCartModel.h"
#import "UpdateItemCartModel.h"
#import "PlaceOrderModel.h"
//End

NSString *const QuoteWillRequestNotification = @"QuoteWillRequestNotification";
NSString *const QuoteDidRequestNotification = @"QuoteDidRequestNotification";
NSString *const QuoteEndRequestNotification = @"QuoteEndRequestNotification";

NSString *const QuoteFailtRequestNotification = @"QuoteFailtRequestNotification";

@interface Quote()
//Ravi
{
    AddToCartModel *addToCartModel;
    int *numbAddingCart;
    BOOL getedItems;
    BOOL getedTotals;
}
//End
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
        //Ravi
        numbAddingCart = 0;
        addToCartModel = [AddToCartModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddToCart:) name:@"DidAddToCart" object:nil];
        //End
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
    
    //ravi
    getedTotals = NO;
    TotalsCartModel *totalsCartModel = [TotalsCartModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTotalsCart:) name:@"DidGetTotalsCart" object:nil];
    [totalsCartModel getTotalsCart];
    
    return;
    //end
    
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
    //Ravi
     [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:nil userInfo:nil];
    numbAddingCart ++;
    [addToCartModel addToCartWidthProductId:nil options:options];
    return;
    //End
    
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
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:nil userInfo:nil];
    numbAddingCart ++;
    [addToCartModel addToCartWidthProductId:[product valueForKey:@"id"] options:options];
    return;
    //End
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:product userInfo:nil];
    QuoteResource *resource = [[QuoteResource alloc] init];
    // Attach data to resource
    resource.product = product;
    if (options != nil) {
        resource.options = [options copy];  //[options mutableDeepCopy];
    }
    [resource updateItemRequest:[product getId] method:@"add"];
    
    self.numberOfUpdate--;
    
    [self changeQuoteData];
    if (self.loadQuoteItemState) {
        self.loadQuoteItemState--;
    }
    self.numberOfUpdate++;
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:product userInfo:nil];
    
}

- (void)updateItem:(id)itemId withOptions:(NSDictionary *)options
{
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateItemCart:) name:@"DidUpdateItemCart" object:nil];
    UpdateItemCartModel *updateItemModel = [UpdateItemCartModel new];
    [updateItemModel updateItemCartWithID:itemId options:options qty:nil price:nil];
    return;
    //End
    
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
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateItemCart:) name:@"DidUpdateItemCart" object:nil];
    UpdateItemCartModel *updateItemModel = [UpdateItemCartModel new];
    [updateItemModel updateItemCartWithID:itemId options:nil qty:nil price:price];
    return;
    //End
    
    
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
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:itemId userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateItemCart:) name:@"DidUpdateItemCart" object:nil];
    UpdateItemCartModel *updateItemModel = [UpdateItemCartModel new];
    [updateItemModel updateItemCartWithID:itemId options:nil qty:[NSString stringWithFormat:@"%.0f",qty] price:nil];
    return;
    //End
    
    
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
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteItemCart:) name:@"DidDeleteItemCart" object:nil];
    DeleteItemCartModel *deleteItemModel = [DeleteItemCartModel new];
    [deleteItemModel deleteItemCartWidthId:itemId];
    
    return;
    //End
    
    
    
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
    //Ravi need check bar code
    
    //End
    
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
    //Ravi
    [self clearOrderIdSession];
    if ([self totalItemsQty] == 0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClearCart:) name:@"DidClearCart" object:nil];
    ClearCartModel *clearCart = [ClearCartModel new];
    [clearCart clearCart];
    
    
    
    return;
    //End
    
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
//        if ([[obj objectForKey:@"code"] isEqualToString:@"grand_total"]) {
//            continue;
//        }
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


//Ravi
- (NSNumber *)getShipping
{
    for (id obj in [self.totals allValues]) {
        if ([[obj objectForKey:@"code"] isEqualToString:@"shipping"]) {
            return [obj objectForKey:@"amount"];
        }
    }
    return [NSNumber numberWithInt:0];
}
//End

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
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:nil userInfo:nil];
    self.customer = customer;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAssignCustomer:) name:@"DidAssignCustomer" object:nil];
    AssignCustomerModel *assignCustomerModel = [AssignCustomerModel new];
    [assignCustomerModel assignCustomerWithCustomerID:[customer valueForKey:@"id"]];
    return;
    //End
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
    //Ravi
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteWillRequestNotification object:nil userInfo:nil];
    self.customer = customer;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAssignCustomer:) name:@"DidAssignCustomer" object:nil];
    AssignCustomerModel *assignCustomerModel = [AssignCustomerModel new];
    [assignCustomerModel assignCustomerWithCustomerID:[customer valueForKey:@"id"]];
    return;
    //End
    
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
    //Ravi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:@"DidPlaceOrder" object:nil];
    PlaceOrderModel *placeOrderModel = [PlaceOrderModel new];
    [placeOrderModel placeOrderWidthOptions:config];
    return;
    //End
    
    
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

//Ravi
- (void)didAddToCart : (NSNotification *)noti{
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    numbAddingCart --;
    if([respone.status isEqualToString:@"SUCCESS"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseDetailPage" object:nil];
        DLog(@"didAddToCart - %@",respone.data);
        if (numbAddingCart == 0 ) {
            [self getItemsAndTotals];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addToCartFailure" object:nil];
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didGetItemsCart : (NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didGetItemsCart - %@",respone.data);
        getedItems = YES;
    
        if (self.quoteItems == nil) {
            self.quoteItems = [[NSMutableArray alloc] init];
        }else{
            [self.quoteItems removeAllObjects];
        }

        if ([respone.data isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in [respone.data allKeys]) {
                QuoteItem *item = [QuoteItem new];
                [item setData:[respone.data valueForKey:key]];
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
                
                
                [self.quoteItems addObject:item];
            }
        }
        if (getedItems && getedTotals) {
            [self refreshCart];
        }
    }else{
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Get Items Cart" message: [NSString stringWithFormat:@"%@ : Pull to refresh", [respone.message objectAtIndex:0]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didGetTotalsCart : (NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didGetTotalsCart - %@",respone.data);
        getedTotals = YES;
        [self.totals removeAllObjects];
        if ([respone.data isKindOfClass:[NSDictionary class]]) {
            [self.totals addEntriesFromDictionary:respone.data];
        }
        if (getedItems && getedTotals) {
            [self refreshCart];
        }
    }else{
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Get Totals Cart" message: [NSString stringWithFormat:@"%@ : Pull to refresh", [respone.message objectAtIndex:0]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didAssignCustomer: (NSNotification*)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didAssignCustomer - %@",respone.data);
        [self setValue:[self.customer getId] forKey:@"customer_id"];
        [self setValue:[self.customer objectForKey:@"email"] forKey:@"customer_email"];
        [self setValue:[self.customer objectForKey:@"telephone"] forKey:@"customer_telephone"];
        [self setValue:[self.customer objectForKey:@"name"] forKey:@"customer_name"];
        
        if ([[self objectForKey:@"customer_group_id"] integerValue] != [[self.customer objectForKey:@"group_id"] integerValue]) {
            [self setValue:[self.customer objectForKey:@"group_id"] forKey:@"customer_group_id"];
        }
        [self getItemsAndTotals];
    }else{
        [self.customer removeAllObjects];
        [self setValue:[NSNull new] forKey:@"customer_id"];
        [self setValue:@"0" forKey:@"customer_group_id"];
        [self setValue:[NSNull new] forKey:@"customer_email"];
        [self setValue:@" " forKey:@"customer_telephone"];
        [self setValue:@" " forKey:@"customer_name"];
        
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didDeleteItemCart: (NSNotification*)noti {
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didDeleteItemCart - %@",respone.data);
        [self getItemsAndTotals];
    }else{
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didClearCart: (NSNotification*)noti{
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didClearCart - %@",respone.data);
        if (self.quoteItems != nil) {
            [self.quoteItems removeAllObjects];
        }
        [self.totals removeAllObjects];
        [self refreshCart];
    }else{
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didUpdateItemCart: (NSNotification*)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didUpdateItemCart - %@",respone.data);
        [self getItemsAndTotals];
    }else{
        [self refreshCart];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didPlaceOrder : (NSNotification*)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didPlaceOrder - %@",respone.data);
        
        QuoteResource *resource = [QuoteResource new];
        [resource addEntriesFromDictionary:respone.data];
        
        if (self.order == nil && [resource objectForKey:@"order"]) {
            self.order = [Order new];
            [self.order addData:resource];
            [self.order setValue:[resource objectForKey:@"order"] forKey:@"id"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QuotePlaceOrderSuccess" object:nil];

    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"placeOrderFail" object:nil];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}



- (void)refreshCart{
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteDidRequestNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:QuoteEndRequestNotification object:nil];
}

- (void)getItemsAndTotals{
    DLog(@" ------------- Load items + load totals -------------- ");
    getedItems = NO;
    getedTotals = NO;
    ItemsCartModel *itemsCartModel = [ItemsCartModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetItemsCart:) name:@"DidGetItemsCart" object:nil];
    [itemsCartModel getItemsCart];
    
    TotalsCartModel *totalsCartModel = [TotalsCartModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTotalsCart:) name:@"DidGetTotalsCart" object:nil];
    [totalsCartModel getTotalsCart];
}

//End

@end
