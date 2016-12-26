//
//  PaymentViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/28/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentViewController.h"
#import "Quote.h"

#import "CreditCardFormController.h"
#import "PurchaseOrderFormController.h"
#import "OfflinePaymentFormController.h"

#import "WebposPaymentsFormController.h"
#import "WebposMultipaymentsFormController.h"

@implementation PaymentViewController

@synthesize checkout, collection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collection = self.checkout.collection;
    self.tableView.rowHeight = 80;
    
    Payment *payment = [Quote sharedQuote].payment;
    [payment setValue:GetStringValue(KEY_DEFAULT_PAYMENT_METHOD) forKey:@"method"];
    [self.checkout reloadButtonStatus];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.collection getSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"PaymentMethodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont systemFontOfSize:20];
    }
    
    Payment *method = [self.collection objectAtIndex:[indexPath row]];
    Payment *payment = [Quote sharedQuote].payment;
    
    NSString * methodID =[method getId];
    
    //NSLog(@"methodid:%@",methodID);
    //NSLog(@"default payment:%@",GetStringValue(KEY_DEFAULT_PAYMENT_METHOD));
    
    //if([methodID isEqualToString:GetStringValue(KEY_DEFAULT_PAYMENT_METHOD)]){
    if ([payment isCurrentMethod:method]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        Payment *payment = [Quote sharedQuote].payment;
        [payment setValue:methodID forKey:@"method"];
        payment.instance = method;
        
        [self.checkout reloadButtonStatus];
        
    } else if ([method hasOptionForm]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [method objectForKey:@"title"];
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] >= [self.collection getSize]) {
        [self.checkout reloadData];
        return;
    }
    Payment *method = [self.collection objectAtIndex:[indexPath row]];
    
    Payment *payment = [Quote sharedQuote].payment;
    if (![payment isCurrentMethod:method]) {
        [payment setValue:[method getId] forKey:@"method"];
        for (NSUInteger i = 0; i < [self.collection getSize]; i++) {
            if ([payment.instance isEqual:[self.collection objectAtIndex:i]]) {
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
        payment.instance = method;
    }
    
    if ([method hasOptionForm]) {
        // Go to Option form
        PaymentFormAbstract *paymentForm;
        if ([method isCreditCardMethod]) {
            paymentForm = [[CreditCardFormController alloc] init];
        } else if ([[method getId] isEqualToString:@"purchaseorder"]) {
            paymentForm = [[PurchaseOrderFormController alloc] init];
        } else if ([[method getId] containsString:@"multipayment"]) {
            paymentForm = [[WebposMultipaymentsFormController alloc] init];
        } else if ([[method getId] containsString:@"forpos"]) {
            paymentForm = [[WebposPaymentsFormController alloc] init];
        } else {
            paymentForm = [[OfflinePaymentFormController alloc] init];
        }
        if (paymentForm != nil) {
            paymentForm.checkout = self.checkout;
            paymentForm.method = method;
            [self.navigationController pushViewController:paymentForm animated:YES];
        }
    }
    [self.checkout reloadButtonStatus];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
