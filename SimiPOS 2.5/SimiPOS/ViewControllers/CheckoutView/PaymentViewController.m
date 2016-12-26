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

//Ravi payment authorize.net
#import "IDTechSwipeViewController.h"
//End

//Ravi payment PayPalHere
#import "PayPalHereSDKViewController.h"
//End

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
    
    //RAVI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncheckPayment) name:@"uncheckPaymentMethod" object:nil];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadPaymentList)
                    forControlEvents:UIControlEventValueChanged];

    //END
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
    
    DLog(@"%@",method);
    DLog(@"%@",payment);
    
    NSString * methodID =[method getId];
    
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
        
        //Ravi payment authorize.net
        if ([[method getId] isEqualToString:@"authorizenet"]) {
            paymentForm = [[IDTechSwipeViewController alloc] init];
        } else
        //End
        
        //Ravi payment PayPal Here
        if ([[method getId] isEqualToString:@"paypalhere"]) {
            if ([[Quote sharedQuote].shipping allKeys].count > 0) {
                paymentForm = [[PayPalHereSDKViewController alloc] init];
                MSNavigationController *navControl = [[MSNavigationController alloc] initWithRootViewController:paymentForm];
                navControl.modalPresentationStyle = UIModalPresentationPageSheet;
                [self.checkout reloadButtonStatus];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self presentViewController:navControl animated:YES completion:nil];
            } else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please choose shippingMethod" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            return;
        } else
        //End
            
        if ([method isCreditCardMethod]) {
            paymentForm = [[CreditCardFormController alloc] init];
        }
        else if ([[method getId] isEqualToString:@"purchaseorder"]) {
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

//ravi
-(void) uncheckPayment{
    [[Quote sharedQuote].payment setValue:@"" forKey:@"method"];
    [self.tableView reloadData];
    [self.checkout reloadButtonStatus];
}


- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (void)reloadPaymentList{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPaymentList" object:nil];
}

//End

@end
