//
//  Paypalhere.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/15/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "Paypalhere.h"
#import "Quote.h"
#import "MSFramework.h"
#import "Configuration.h"
#import "CheckoutViewController.h"

@interface Paypalhere()
@property (strong, nonatomic) NSMutableDictionary *invoice;
@property (weak, nonatomic) CheckoutViewController *checkout;
@end

@implementation Paypalhere
@synthesize invoice, checkout;

+ (Paypalhere *)sharedModel
{
    return (Paypalhere *)[Configuration getSingleton:@"Paypalhere"];
}

- (void)openPaypalHereApp:(CheckoutViewController *)checkoutVC
{
    checkout = checkoutVC;
    Quote *quote = [Quote sharedQuote];
    NSDictionary *merchant = [quote.payment.instance objectForKey:@"merchant"];
    if (invoice == nil) {
        invoice = [NSMutableDictionary new];
    } else {
        [invoice removeAllObjects];
    }
    // Start Generate Invoice
    [invoice setValue:@"DueOnReceipt" forKey:@"paymentTerms"];
    [invoice setValue:[quote objectForKey:@"currency_code"] forKey:@"currencyCode"];
    [invoice setValue:[merchant objectForKey:@"business_account"] forKey:@"merchantEmail"];
    if ([MSValidator validateEmail:[quote objectForKey:@"customer_email"]]) {
        [invoice setValue:[quote objectForKey:@"customer_email"] forKey:@"payerEmail"];
    } else {
        [invoice setValue:@"guest@magestore.com" forKey:@"payerEmail"];
    }
    if ([[merchant objectForKey:@"line_items_enabled"] boolValue]) {
        // Generate both Items and Totals
        [self generateLineItems];
    } else {
        // Only generate Grand Total
        [self generateGrandTotal];
    }
    // Prepare request data
    NSString *jsonInvoice = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:invoice options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *encodedInvoice = [jsonInvoice stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *encodedPaymentTypes = [[merchant objectForKey:@"accepted_method"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *encodedReturnUrl = [@"simipos://takePayment?{result}?Type={Type}&InvoiceId={InvoiceId}&Tip={Tip}&Email={Email}&TxId={TxId}" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *pphUrlString = [NSString stringWithFormat:@"paypalhere://takePayment?accepted=%@&returnUrl=%@&invoice=%@&step=choosePayment", encodedPaymentTypes, encodedReturnUrl, encodedInvoice];
    NSURL *pphUrl = [NSURL URLWithString:pphUrlString];
    // Open PPH app
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:pphUrl]) {
        [application openURL:pphUrl];
    } else {
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/paypal-here-for-ipad/id607485062?mt=8"];
        [application openURL:url];
    }
    invoice = nil;
}

- (void)generateGrandTotal
{
    NSDictionary *posItem = @{
        @"name" : @"POS Order",
        @"quantity" : @1,
        @"unitPrice" : [[Quote sharedQuote] getGrandTotal]
    };
    [invoice setValue:@{@"item": @[posItem]} forKey:@"itemList"];
}

- (void)generateLineItems
{
    Quote *quote = [Quote sharedQuote];
    // Items
    NSMutableArray *items = [NSMutableArray new];
    NSMutableArray *taxRates = [NSMutableArray new];
    long double total = 0;
    
    for (QuoteItem *quoteItem in [quote getAllItems]) {
        NSMutableDictionary *item = [NSMutableDictionary new];
        [item setValue:[quoteItem getName] forKey:@"name"];
        [item setValue:[NSNumber numberWithFloat:[quoteItem getQty]] forKey:@"quantity"];
        [item setValue:[quoteItem getPrice] forKey:@"unitPrice"];
        // Update total
        long double rowTotal = [quoteItem getQty] * [[quoteItem getPrice] doubleValue];
        total += rowTotal;
        // Check for tax
        if ([[quoteItem objectForKey:@"tax_percent"] floatValue] > 0.001) {
            CGFloat newTaxRate = [[quoteItem objectForKey:@"tax_percent"] floatValue];
            [item setValue:[NSNumber numberWithFloat:newTaxRate] forKey:@"taxRate"];
            total += rowTotal * newTaxRate / 100;
            for (NSUInteger index = 0; index < [taxRates count]; index++) {
                if ([[taxRates objectAtIndex:index] floatValue] == newTaxRate) {
                    if (index == 0) {
                        [item setValue:@"Tax" forKey:@"taxName"];
                    } else {
                        [item setValue:[NSString stringWithFormat:@"Tax %d", index] forKey:@"taxName"];
                    }
                    newTaxRate = 0;
                }
            }
            if (newTaxRate) {
                if ([taxRates count]) {
                    [item setValue:[NSString stringWithFormat:@"Tax %d", [taxRates count]] forKey:@"taxName"];
                } else {
                    [item setValue:@"Tax" forKey:@"taxName"];
                }
                // Add New Rate
                [taxRates addObject:[NSNumber numberWithFloat:newTaxRate]];
            }
        }
        [items addObject:item];
    }
    [invoice setValue:@{@"item": items} forKey:@"itemList"];
    
    // Totals (Shipping And Discount)
    for (id obj in [quote.totals allValues]) {
        if ([[obj objectForKey:@"code"] isEqualToString:@"discount"]) {
            total += [[obj objectForKey:@"amount"] doubleValue];
            NSString *discountAmount = (NSString *)[obj objectForKey:@"amount"];
            if ([discountAmount isKindOfClass:[NSNumber class]]) {
                discountAmount = [(NSNumber *)discountAmount stringValue];
            }
            discountAmount = [discountAmount stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [invoice setValue:discountAmount forKey:@"discountAmount"];
        } else if ([[obj objectForKey:@"code"] isEqualToString:@"shipping"]) {
            total += [[obj objectForKey:@"amount"] doubleValue];
            [invoice setValue:[obj objectForKey:@"amount"] forKey:@"shippingAmount"];
        }
    }
    
    // Adjustment
    long double grandTotal = [[quote getGrandTotal] doubleValue];
    if (quote.cashIn > 0.001) {
        grandTotal -= quote.cashIn;
        if (grandTotal < 0.001) {
            grandTotal = 0.0;
        }
    }
    if (ABS(grandTotal - total) > 0.01) {
        [invoice setValue:@"Adjustment" forKey:@"customAmountLabel"];
        [invoice setValue:[NSNumber numberWithDouble:(grandTotal - total)] forKey:@"customAmountValue"];
    }
}

// Process callback payment
- (void)processPayment:(NSURL *)url
{
    if (checkout == nil || [MSValidator isEmptyString:[[Configuration globalConfig] objectForKey:@"session"]] || [MSValidator isEmptyString:[[Quote sharedQuote] getId]]) {
        checkout = nil;
        return;
    }
    NSString *query = [[url query] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    NSDictionary *params = [self parseString:query];
    if ([MSValidator isEmptyString:[params objectForKey:@"Type"]]
        || [[params objectForKey:@"Type"] isEqualToString:@"Unknown"]
    ) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"An error has occured and the payment has failed. Please try again or select another payment method", nil)];
        checkout = nil;
        return;
    }
    // Checkout use Paypalhere payment method
    Payment *payment = [Quote sharedQuote].payment;
    if (![[payment objectForKey:@"method"] isEqualToString:@"paypalhere"]) {
        [payment setValue:@"paypalhere" forKey:@"method"];
    }
    [payment setValue:query forKey:@"purchased_order"];
    // Start place order
    [checkout placeOrderMain];
    checkout = nil;
}

- (NSDictionary *)parseString:(NSString *)query
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSArray *parts  = [component componentsSeparatedByString:@"="];
        if ([parts count] == 2) {
            [result setValue:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
        }
    }
    return result;
}

@end
